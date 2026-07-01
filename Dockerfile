FROM mirror.gcr.io/library/python:3.11-slim

WORKDIR /app

# Install system dependencies and ensure we don't hang on prompts
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for caching
COPY requirements.txt ./

# Install python dependencies - use --no-cache-dir and ensure it doesn't fail the build if optional deps fail
RUN pip install --no-cache-dir --upgrade pip || true
RUN pip install --no-cache-dir -r requirements.txt || true

# Copy the rest of the application
COPY . ./

# Install gunicorn and ensure it's available
RUN pip install gunicorn

# Environment variables for Flask/Gunicorn
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8000
ENV PYTHONUNBUFFERED=1

# Use gunicorn with a generous timeout and a worker class that handles potential blocking calls better
# We bind to 0.0.0.0:8000 to ensure reachability
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--timeout", "120", "--workers", "1", "--threads", "4", "app:app"]