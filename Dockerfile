# <--------- Stage 1: Builder --------->
FROM python:3.10-slim as builder

WORKDIR /app

# Install build tools safely and clear apt cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies into custom /install path
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# <--------- Stage 2: Hardened Runtime --------->
FROM python:3.10-slim

WORKDIR /app

# Create non-root user (appuser)
RUN adduser --disabled-password --gecos "" appuser

# Set python environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH="/install/lib/python3.10/site-packages" \
    PATH="/install/bin:$PATH"

# Copy installed packages from builder stage
COPY --from=builder /install /install

# Copy application source code
COPY . .

# Change ownership of application files to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000

# Production application runner using Gunicorn
CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]
