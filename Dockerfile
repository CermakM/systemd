## Create Dockerfile that builds container suitable for systemd build
## This container runs as non-root user by deafult

# Use the latest stable version of fedora
FROM fedora:latest

# Copy the requirements into the container at /tmp
COPY requirements.txt /tmp/

ENV PROJECTDIR /builddir/systemd
ENV NOROOT_USER travis

# Install the requirements
RUN dnf -y install $(cat '/tmp/requirements.txt')
RUN dnf clean all && dnf -y builddep systemd  # clean step to prevent cache and metadata corruption

COPY . $PROJECTDIR

# Add non-root user and chown the project dir
RUN useradd --create-home --shell /bin/bash $NOROOT_USER
# change ownership of the project directory to the non-root user
RUN chown -R $NOROOT_USER $PROJECTDIR

USER $NOROOT_USER
WORKDIR $PROJECTDIR
