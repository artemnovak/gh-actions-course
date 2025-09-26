# Pull pre-built CLIs from official images
FROM maniator/gh:latest AS github-cli
FROM hashicorp/terraform:1.13 AS terraform

# Builder stage for Azure CLI and Python packages
FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create venv and install Azure CLI + packages
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir \
    azure-cli \
    ansible-core \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# Final stage
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_NO_CACHE_DIR=1
ENV PYTHONUNBUFFERED=1  

ARG BUILD_DATE
ARG VERSION
ARG BUILDER

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.title="DevOps Toolkit" \
    org.opencontainers.image.description="Universal container with Terraform, Azure CLI, GitHub CLI, Python" \
    com.blueyonder.project="spectrum-pmm-nextgen-pipeline" \
    com.blueyonder.author="${BUILDER}"

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    yq \
    zip \
    unzip \
    ca-certificates \
    python3 \
    python3-venv \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=terraform /bin/terraform /usr/local/bin/terraform
COPY --from=github-cli /usr/bin/gh /usr/local/bin/gh

RUN useradd -m -s /bin/bash azureuser
COPY --from=builder --chown=azureuser:azureuser /opt/venv /opt/venv

USER azureuser
WORKDIR /home/azureuser

ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=azureuser:azureuser requirements.yaml .
RUN ansible-galaxy collection install -r requirements.yaml

RUN set -e; \
    echo "=== Validating installations ===" && \
    terraform -version && \
    az version && \
    gh --version && \
    python3 --version && \
    pip list && \
    ansible --version && \
    ansible-galaxy collection list