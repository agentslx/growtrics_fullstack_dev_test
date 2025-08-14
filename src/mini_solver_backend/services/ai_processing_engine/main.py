import asyncio
from dotenv import load_dotenv
from .di import init_di  # ensure DI bindings are evaluated
from .api.consumer import run_forever

# Load environment variables
def main():
    print("Starting AI Processing Engine...")
    load_dotenv()  # Load environment variables from .env file
    asyncio.run(init_di())
    asyncio.run(run_forever())


if __name__ == "__main__":
    main()
