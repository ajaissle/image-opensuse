## -*- docker-image-name: "armbuild/ocs-distrib-opensuse:13.2" -*-
FROM armbuild/opensuse-disk:13.2
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Environment
ENV SCW_BASE_IMAGE armbuild/scw-distrib-opensuse:13.2


# Patch rootfs for docker-based builds
RUN zypper -n -v refresh \
 && zypper -n update \
 && zypper -n install curl \
 && curl -Lq http://j.mp/scw-skeleton | FLAVORS=common,docker-based bash -e \
 && /usr/local/sbin/builder-enter


# Make the image smaller
# kernel, drivers, firmwares
RUN zypper rm -n kernel-default kernel-firmware
# services
RUN zypper rm -n libmozjs-17_0 bluez cracklib-dict-full


# Install packages
RUN zypper -n install \
    bc \
    shunit2 \
    socat \
    sudo \
    tmux \
    vim \
    wget


# Locale
RUN cd /usr/lib/locale/; ls | grep -v en_US | xargs rm -rf


# Patch rootfs
RUN curl -Lkq http://j.mp/scw-skeleton | FLAVORS=common,docker-based bash -e
ADD ./patches/etc/ /etc/
#ADD ./patches/usr/ /usr/


RUN systemctl enable oc-ssh-keys


# Remove root password
RUN passwd -d root


# Disable YaST2 on first boot
RUN systemctl disable YaST2-Firstboot.service


RUN systemctl disable systemd-modules-load.service

# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
