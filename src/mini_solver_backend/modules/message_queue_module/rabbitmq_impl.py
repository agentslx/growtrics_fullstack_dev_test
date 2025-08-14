import asyncio
import json
import os
from typing import Any, Dict, Optional, Union

import aio_pika

from .message_queue_module import MessageQueueModule, MessageHandler


class RabbitMQModule(MessageQueueModule):
    """RabbitMQ implementation using aio-pika."""

    def __init__(self, url: Optional[str] = None):
        # amqp://user:pass@host:5672/vhost
        self.url = url or os.getenv("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/")
        self._conn: Optional[aio_pika.RobustConnection] = None
        self._channel: Optional[aio_pika.abc.AbstractChannel] = None

    async def connect(self) -> None:
        self._conn = await aio_pika.connect_robust(self.url)
        self._channel = await self._conn.channel()

    async def close(self) -> None:
        if self._channel and not self._channel.is_closed:
            await self._channel.close()
        if self._conn and not self._conn.is_closed:
            await self._conn.close()

    async def _ensure(self):
        if self._conn is None or self._conn.is_closed:
            await self.connect()
        if self._channel is None or self._channel.is_closed:
            self._channel = await self._conn.channel()

    async def declare_queue(
        self,
        name: str,
        durable: bool = True,
        dead_letter_exchange: Optional[str] = None,
        dead_letter_routing_key: Optional[str] = None,
    ) -> None:
        await self._ensure()
        arguments: Dict[str, Any] = {}
        if dead_letter_exchange:
            arguments["x-dead-letter-exchange"] = dead_letter_exchange
        if dead_letter_routing_key:
            arguments["x-dead-letter-routing-key"] = dead_letter_routing_key
        await self._channel.declare_queue(name, durable=durable, arguments=arguments or None)

    async def purge_queue(self, name: str) -> None:
        await self._ensure()
        queue = await self._channel.declare_queue(name, durable=True)
        await queue.purge()

    async def delete_queue(self, name: str, if_unused: bool = False, if_empty: bool = False) -> None:
        await self._ensure()
        await self._channel.queue_delete(name, if_unused=if_unused, if_empty=if_empty)

    async def publish(
        self,
        queue: str,
        body: Union[str, bytes, Dict[str, Any]],
        *,
        headers: Optional[Dict[str, Any]] = None,
        content_type: Optional[str] = None,
        persistent: bool = True,
    ) -> None:
        await self._ensure()
        if isinstance(body, dict):
            payload = json.dumps(body).encode("utf-8")
            ct = content_type or "application/json"
        elif isinstance(body, str):
            payload = body.encode("utf-8")
            ct = content_type or "text/plain"
        else:
            payload = body
            ct = content_type or "application/octet-stream"

        msg = aio_pika.Message(
            payload,
            content_type=ct,
            headers=headers or {},
            delivery_mode=aio_pika.DeliveryMode.PERSISTENT if persistent else aio_pika.DeliveryMode.NOT_PERSISTENT,
        )
        # Use default exchange to route to queue by name
        assert self._channel is not None
        await self._channel.default_exchange.publish(msg, routing_key=queue)

    async def consume(
        self,
        queue: str,
        handler: MessageHandler,
        *,
        prefetch_count: int = 1,
        auto_ack: bool = False,
        durable: bool = True,
    ) -> None:
        await self._ensure()
        assert self._channel is not None
        await self._channel.set_qos(prefetch_count=prefetch_count)
        q = await self._channel.declare_queue(queue, durable=durable)

        tasks = set()

        async def _process(msg: aio_pika.IncomingMessage):
            try:
                await handler(msg.body, dict(msg.headers or {}))
                if not auto_ack:
                    await msg.ack()
            except Exception:
                if not auto_ack:
                    await msg.nack(requeue=False)

        async with q.iterator() as queue_iter:
            async for msg in queue_iter:
                # spawn a task per message to allow concurrency up to prefetch_count
                task = asyncio.create_task(_process(msg))
                tasks.add(task)
                task.add_done_callback(lambda t: tasks.discard(t))
                await asyncio.sleep(0)
