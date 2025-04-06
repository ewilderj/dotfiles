FROM ubuntu:latest

RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    make \
    curl \
    zsh \
    vim \
    emacs-nox \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*


# Create a test user
RUN useradd -m -s /bin/zsh testuser
USER testuser
WORKDIR /home/testuser

# chezmoi dotfile manager
USER testuser
WORKDIR /home/testuser/
RUN sh -c "$(curl -fsLS get.chezmoi.io)"

WORKDIR /home/testuser/dotfiles
# Copy dotfiles repository
COPY --chown=testuser:testuser . /home/testuser/dotfiles/

# Use systemd as the entry point
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd", "--system"]