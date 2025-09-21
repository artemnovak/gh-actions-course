FROM alpine:3.19

# Update package index and install base packages
RUN apk update && apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    bash \
    curl \
    wget \
    git \
    openssh-client \
    ca-certificates \
    jq \
    yq \
    build-base \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip

# Install pipx
RUN pip3 install pipx && pipx ensurepath

# Add pipx to PATH
ENV PATH="/root/.local/bin:$PATH"

# Install Azure CLI (simplified)
RUN pip3 install azure-cli

# Install Terraform
ARG TERRAFORM_VERSION=1.6.6
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Ansible via pip
RUN pip3 install ansible

# Set working directory
WORKDIR /workspace