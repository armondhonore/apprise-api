FROM mirror.gcr.io/library/python:3.11-slim

WORKDIR /app

# Install system dependencies for Apprise and potential extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Apprise-API typically runs via a python script or a module
# Based on common patterns for this repo, we use the main entry point
CMD ["python", "app.py"]