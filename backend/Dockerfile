# Using the cuda ubuntu 20.04 image for production so it should have 
# all the cuda, cudnn, and nvidia drivers installed toolkits everything working
FROM nvidia/cuda:11.6.1-devel-ubuntu20.04 as base

# Install basic packages
RUN apt update && apt install -y \
        python3 \
        python3-pip \
        git \
        wget \
        curl \
        nano \
        openssh-server \
        ffmpeg \
        build-essential \
        cmake \
        libsox-dev \
        pkg-config \
        libgl1-mesa-glx \
        tmux \
        espeak-ng \
        libspeak1 \
    apt clean && rm -rf /var/lib/apt/lists/* && \
    echo "root:{API_SECRET}" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Setup repo
RUN git config --global credential.helper store && \
    git clone https://${GIT_TOKEN}@github.com/scribs-ai/v3.1.git /app && \
    cd /app && \
    git submodule update --init --recursive

# Setup working directory
WORKDIR /app/backend

# Install Poetry
RUN pip install --no-cache-dir poetry

# Install dependencies with in a venv with poetry
RUN poetry config virtualenvs.create false && \
    poetry install --no-root -C backend/v3_1

# Run the server with git pull to get the latest changes
# in the github workflow, it will only build the image if there is a change in the Dockerfile or the pyproject.toml
# so hotfixes can be deployed without having to rebuild the image
EXPOSE 8000
CMD git pull && poetry shell -C backend/v3_1 && uvicorn backend.v3_1.src.main:app --host 0.0.0.0 --port 8000
