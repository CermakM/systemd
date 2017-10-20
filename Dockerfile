# Use the latest stable version of fedora
FROM fedora:latest

# Copy the requirements into the container at /tmp
COPY requirements.txt /tmp/

# Install the requirements
RUN dnf -y install $(cat '/tmp/requirements.txt')
RUN dnf -y builddep systemd

COPY . /builddir/systemd/

WORKDIR /builddir/systemd/
