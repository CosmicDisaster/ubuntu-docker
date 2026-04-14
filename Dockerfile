FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER_NAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000
ARG APT_PACKAGES="ca-certificates curl wget git gnupg lsb-release software-properties-common openssh-server sudo build-essential make pkg-config python3 python3-dev python3-venv python3-pip pipx nodejs npm jq ripgrep fd-find tree tmux htop less nano vim zip unzip rsync procps net-tools iproute2 iputils-ping dnsutils locales tzdata"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${APT_PACKAGES} \
    && rm -rf /var/lib/apt/lists/*

RUN if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then \
      ln -s /usr/bin/fdfind /usr/local/bin/fd; \
    fi

RUN groupadd --gid "${USER_GID}" "${USER_NAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USER_NAME}" \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_NAME}" \
    && chmod 0440 "/etc/sudoers.d/${USER_NAME}"

RUN mkdir -p /var/run/sshd \
    && mkdir -p "/home/${USER_NAME}/.ssh" \
    && chown -R "${USER_UID}:${USER_GID}" "/home/${USER_NAME}/.ssh" \
    && chmod 700 "/home/${USER_NAME}/.ssh" \
    && printf "PasswordAuthentication no\nPubkeyAuthentication yes\nPermitRootLogin no\n" > /etc/ssh/sshd_config.d/10-hardening.conf \
    && printf "AllowUsers %s\n" "${USER_NAME}" > /etc/ssh/sshd_config.d/99-user.conf

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

COPY scripts/container-init.sh /usr/local/bin/container-init.sh
RUN chmod +x /usr/local/bin/container-init.sh

WORKDIR /workspace
EXPOSE 22

CMD ["/usr/local/bin/container-init.sh"]
