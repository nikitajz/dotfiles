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

# Set up the test environment
WORKDIR /root/.dotfiles
COPY . .

# Set entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["./install_ubuntu.sh && ./tests/run_tests.sh"] 