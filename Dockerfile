FROM --platform=linux/arm64/v8 ubuntu:latest

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential dependencies first
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    zsh \
    tzdata \
    locales \
    sudo \
    procps \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user
RUN groupadd --gid 1000 ubuntu || true && \
    useradd --uid 1000 --gid 1000 --shell /bin/zsh --create-home ubuntu || true && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set environment variables for the test user
ENV HOME=/home/ubuntu
ENV USER=ubuntu
ENV SHELL=/bin/zsh

# Set up the test environment
WORKDIR /home/ubuntu/.dotfiles
COPY --chown=ubuntu:ubuntu . .

# Switch to the non-root user
USER ubuntu

# XDG directories should be set in the installation script!

# Set entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["./install_ubuntu.sh && ./tests/run_tests.sh --local"] 