from abc import ABC, abstractmethod
from typing import Any, Awaitable, Callable, Dict, Optional, Union


MessageHandler = Callable[[bytes, Dict[str, Any]], Awaitable[None]]


class MessageQueueModule(ABC):
    """Abstract interface for a message queue module."""

    @abstractmethod
    async def connect(self) -> None:
        """Establish the connection to the message broker."""
        raise NotImplementedError

    @abstractmethod
    async def close(self) -> None:
        """Close the connection to the message broker."""
        raise NotImplementedError

    @abstractmethod
    async def declare_queue(
        self,
        name: str,
        durable: bool = True,
        dead_letter_exchange: Optional[str] = None,
        dead_letter_routing_key: Optional[str] = None,
    ) -> None:
        """Declare a queue (idempotent)."""
        raise NotImplementedError

    @abstractmethod
    async def purge_queue(self, name: str) -> None:
        """Purge all messages from a queue."""
        raise NotImplementedError

    @abstractmethod
    async def delete_queue(self, name: str, if_unused: bool = False, if_empty: bool = False) -> None:
        """Delete a queue."""
        raise NotImplementedError

    @abstractmethod
    async def publish(
        self,
        queue: str,
        body: Union[str, bytes, Dict[str, Any]],
        *,
        headers: Optional[Dict[str, Any]] = None,
        content_type: Optional[str] = None,
        persistent: bool = True,
    ) -> None:
        """Publish a message to a queue (direct routing via default exchange)."""
        raise NotImplementedError

    @abstractmethod
    async def consume(
        self,
        queue: str,
        handler: MessageHandler,
        *,
        prefetch_count: int = 1,
        auto_ack: bool = False,
        durable: bool = True,
    ) -> None:
        """Start consuming messages on a queue. Runs until cancelled."""
        raise NotImplementedError
