# Use the latest stable version of fedora
FROM fedora:latest

# Copy the requirements into the container at /tmp
COPY requirements.txt /tmp/

ENV BULDDIR /builddir
ENV PROJECT systemd

# Install the requirements
RUN dnf -y install $(cat '/tmp/requirements.txt')
RUN dnf clean all && dnf -y builddep systemd  # clean step to prevent cache and metadata corruption

COPY . $BULDDIR/$PROJECT/
WORKDIR $BULDDIR/$PROJECT/
