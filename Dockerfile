## Create Dockerfile that builds container suitable for systemd build
## This container runs as non-root user by deafult

# Use the latest stable version of fedora
FROM fedora:latest

# Demand the specification of non-root username
ARG DOCKER_USER

# Copy the requirements into the container at /tmp
COPY requirements.txt /tmp/

# Install the requirements
RUN dnf -y update
RUN dnf -y install $(cat '/tmp/requirements.txt')
# clean step to prevent cache and metadata corruption
RUN dnf clean all
RUN dnf -y builddep systemd

# Add non-root user and chown the project dir
RUN useradd --create-home --shell /bin/bash $DOCKER_USER
ENV PROJECTDIR /home/$DOCKER_USER/systemd

# Copy content to the project directory
COPY . $PROJECTDIR

# Switch to noroot user by default
USER $DOCKER_USER

WORKDIR $PROJECTDIR
