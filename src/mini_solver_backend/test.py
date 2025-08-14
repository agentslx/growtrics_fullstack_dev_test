import json
import os
import uuid
import asyncio
import argparse
import mimetypes
from typing import Any, Dict, Optional

from dotenv import load_dotenv

# Import modules from the aggregated package
from modules import LocalFileStorageModule, RabbitMQModule


async def send_request(
    image_path: str,
    prompt: Optional[str],
    queue: str,
    reply_queue: str,
    user_id: Optional[str],
    remote_prefix: str,
) -> None:
    # Prepare modules
    storage = LocalFileStorageModule()
    mq = RabbitMQModule()

    request_id = str(uuid.uuid4())
    _, ext = os.path.splitext(image_path)
    if not ext:
        # try to guess from mimetype
        guessed, _ = mimetypes.guess_type(image_path)
        if guessed and "/" in guessed:
            ext = "." + guessed.split("/")[-1]
        else:
            ext = ".jpg"

    remote_path = f"{remote_prefix}/{request_id}/image{ext}"
    content_type, _ = mimetypes.guess_type(image_path)

    print(f"Uploading '{image_path}' to storage at '{remote_path}'...")
    url = await storage.upload_file(image_path, remote_path, content_type=content_type)
    print(f"Uploaded. Accessible URL (may be signed/public depending on bucket): {url}")

    payload = {
        "id": request_id,
        "image_path": remote_path,  # this is what the engine expects to download
        "prompt": prompt,
        "user_id": user_id,
        "reply_queue": reply_queue,
    }

    await mq.connect()
    await mq.declare_queue(queue)
    await mq.declare_queue(reply_queue)  # ensure it exists for the engine to publish back

    print(f"Publishing request to '{queue}' with id={request_id}...")
    await mq.publish(queue, payload)

    await mq.close()
    print("Done. Waiting for the engine to process and publish to:", reply_queue)

    handled_result = False

    async def handler(body: bytes, headers: Dict[str, Any]):
        try:
            payload = json.loads(body.decode("utf-8"))

            print("Received payload:", payload)

            id = payload.get("request_id")
            if id == request_id:
                handled_result = True
                print("Received result for request_id:", id)
                # Should close the call after 1s
                await asyncio.sleep(1)
                await mq.close()
            else:
                print("Ignoring result for different request_id:", id)

            

        except Exception as e:
            # Ignore or log invalid payloads
            print("Error processing payload:", e)
            return

    await mq.consume(reply_queue, handler, prefetch_count=1, auto_ack=True)


def parse_args():
    p = argparse.ArgumentParser(description="Test client to upload image and send solve request")
    p.add_argument("--image", required=True, help="Local image file path to upload")
    p.add_argument("--prompt", default=None, help="Optional prompt to pass to the LLM")
    p.add_argument("--queue", default="solve_requests", help="Request queue name")
    p.add_argument("--reply-queue", default="solve_results", help="Reply queue name for results")
    p.add_argument("--user-id", default=None, help="User id associated with the request")
    p.add_argument(
        "--remote-prefix",
        default="solve_requests",
        help="Remote storage folder prefix for uploaded files",
    )
    return p.parse_args()


def main():
    load_dotenv()
    args = parse_args()
    asyncio.run(
        send_request(
            image_path=args.image,
            prompt=args.prompt,
            queue=args.queue,
            reply_queue=args.reply_queue,
            user_id=args.user_id,
            remote_prefix=args.remote_prefix,
        )
    )


if __name__ == "__main__":
    main()
