FROM python:3.11-slim

WORKDIR /usr/app

# system deps (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /usr/app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Keep container alive for ad-hoc dbt commands, but compose overrides command as needed
CMD ["bash"]
