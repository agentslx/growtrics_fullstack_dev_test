import asyncio
import json
import os
from typing import Any, Dict

from kink import di
from entities.solve_request import SolveRequest
from modules import MessageQueueModule
from ..domain.usecases.process_request import ProcessRequest



async def start_consumer() -> None:
    mq: MessageQueueModule = di[MessageQueueModule]
    usecase: ProcessRequest = di[ProcessRequest]

    incoming_queue = os.getenv("REQUEST_QUEUE", "solve_requests")

    await mq.connect()
    await mq.declare_queue(incoming_queue)

    async def handler(body: bytes, headers: Dict[str, Any]):
        try:
            payload = json.loads(body.decode("utf-8"))

            print("Received payload:", payload)
            req = SolveRequest(**payload)
        except Exception as e:
            # Ignore or log invalid payloads
            print("Error processing payload:", e)
            return
        # process non-blocking
        asyncio.create_task(usecase(req))

    await mq.consume(incoming_queue, handler, prefetch_count=10, auto_ack=True)


async def run_forever():
    try:
        print("Starting AI Processing Engine Consumer...")
        await start_consumer()
    finally:
        try:
            mq: MessageQueueModule = di[MessageQueueModule]
            await mq.close()
        except Exception:
            pass


if __name__ == "__main__":
    asyncio.run(run_forever())
