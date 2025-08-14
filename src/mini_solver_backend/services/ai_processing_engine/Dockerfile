# syntax=docker/dockerfile:1.7-labs

FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system deps for google libs and rabbitmq (openssl, ca-certs) and build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY src/mini_solver_backend/services/ai_processing_engine/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the whole repo (adjust to narrow context if needed)
COPY . .

# Default environment
ENV ENV=production

# Expose nothing (MQ consumer)

# Command: run the service main
CMD ["python", "-m", "services.ai_processing_engine.main"]
