# Use an official Python runtime as the base image
FROM python:3.12-alpine

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Set the working directory in the container
WORKDIR /app

# Install curl for healthcheck (minimal attack surface addition)
RUN apk add --no-cache curl

# Install dependencies first (layer cache friendly)
COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy the rest of the backend files
COPY . /app/

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app
USER appuser

# Expose the port the app runs on
EXPOSE 7001

# Health check using the /probe endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:7001/probe || exit 1

# Command to run the application
CMD ["/bin/sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 7001"]