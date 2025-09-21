FROM alpine:3.19

# Install base packages and Python 3.12
RUN apk add --no-cache \
    python3=~3.12 \
    python3-dev \
    py3-pip \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    cargo \
    rust \
    bash \
    curl \
    wget \
    git \
    openssh-client \
    ca-certificates \
    jq \
    yq \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip

# Install pipx
RUN pip3 install pipx && pipx ensurepath

# Add pipx to PATH
ENV PATH="/root/.local/bin:$PATH"

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash || \
    (apk add --no-cache py3-cryptography && \
     pip3 install azure-cli)

# Install Terraform
ARG TERRAFORM_VERSION=1.6.6
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Ansible via pipx
RUN pipx install ansible-core \
    && pipx install ansible

# Set working directory
WORKDIR /workspace