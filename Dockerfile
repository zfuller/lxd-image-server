ARG distro="ubuntu:focal"
FROM ${distro} AS dpkg-build

RUN apt-get update -qq -o Acquire::Languages=none \
    && env DEBIAN_FRONTEND=noninteractive apt-get install \
        -yqq --no-install-recommends -o Dpkg::Options::=--force-unsafe-io \
        build-essential debhelper dh-exec python3 python3-pip python-dev \
        devscripts python3-virtualenv python3-sphinx python3-sphinx-rtd-theme \
        git equivs python3-mock dh-python pandoc python3-dev python3-venv

# dh-virtualenv does not exist for focal so we need to build it
RUN git clone https://github.com/spotify/dh-virtualenv.git \
    && cd dh-virtualenv \
    && mk-build-deps -ri \
    && dpkg-buildpackage -us -uc -b \
    && dpkg -i ../dh-virtualenv_*.deb

RUN apt-get clean && rm -rf "/var/lib/apt/lists"/*

WORKDIR /dpkg-build
COPY ./ ./

RUN dpkg-buildpackage -us -uc -b && mkdir -p /dpkg && cp -pl /lxd-image-server[-_]* /dpkg  && dpkg-deb -I /dpkg/lxd-image-server_*.deb
