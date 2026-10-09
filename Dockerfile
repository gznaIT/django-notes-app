# <--------- Stage 1: Builder --------->
FROM python:3.10 as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# <--------- Stage 2: Runtime --------->
FROM python:3.10-slim
WORKDIR /app

ENV PYTHONUNBUFFERED=1

# Copy installed packages directly from python site-packages
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
