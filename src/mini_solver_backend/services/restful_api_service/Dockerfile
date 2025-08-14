# syntax=docker/dockerfile:1.7-labs

FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src

# System dependencies (for bcrypt wheels fallback and general SSL)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps first for better caching
COPY src/mini_solver_backend/services/restful_api_service/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the whole project
COPY . .

EXPOSE 5000

# Start the Flask app via gunicorn
# We set PYTHONPATH=/app/src so `mini_solver_backend` is importable
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "services.restful_api_service.main:app"]
