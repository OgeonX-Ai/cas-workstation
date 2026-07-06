# Dockerfile for Scalable Ollama Router

# Use a minimal Ubuntu base
FROM ubuntu:22.04 AS base

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        curl \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*

# Install Ollama (binary distribution)
RUN curl -L https://ollama.com/install.sh | sh

# Copy our routing scripts into the image
COPY scripts/ /opt/ollama-router/scripts/
COPY engineering-os/router/ /opt/ollama-router/router/

# Set working directory
WORKDIR /opt/ollama-router

# Install any Python dependencies (if required by scripts)
RUN pip3 install --no-cache-dir -r scripts/requirements.txt || true

# Expose the Ollama API port (default 11434)
EXPOSE 11434

# Default command runs Ollama server background and keeps container alive
CMD ["/bin/bash", "-c", "ollama serve & while true; do sleep 3600; done"]
