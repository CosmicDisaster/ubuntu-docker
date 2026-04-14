#!/usr/bin/env bash
set -euo pipefail

for cmd in id whoami cat mkdir chmod; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required host command: ${cmd}" >&2
    exit 1
  fi
done

USER_NAME_VALUE="${USER:-$(whoami)}"
USER_UID_VALUE="$(id -u)"
USER_GID_VALUE="$(id -g)"
SSH_PORT_VALUE="${SSH_PORT:-2222}"
APT_PACKAGES_VALUE="${APT_PACKAGES:-ca-certificates curl wget git gnupg lsb-release software-properties-common openssh-server sudo build-essential make pkg-config python3 python3-dev python3-venv python3-pip pipx nodejs npm jq ripgrep fd-find tree tmux htop less nano vim zip unzip rsync procps net-tools iproute2 iputils-ping dnsutils locales tzdata}"

DATA_ROOT="/data/${USER_NAME_VALUE}-ubuntu"
USER_HOME_ROOT="${DATA_ROOT}/home/${USER_NAME_VALUE}"

mkdir -p \
  "${DATA_ROOT}/workspace" \
  "${USER_HOME_ROOT}/.ssh" \
  "${USER_HOME_ROOT}/.config" \
  "${USER_HOME_ROOT}/.local" \
  "${USER_HOME_ROOT}/.npm" \
  "${USER_HOME_ROOT}/.cache/pip" \
  "${USER_HOME_ROOT}/.cache/pipx" \
  "${USER_HOME_ROOT}/.cache/node-gyp"

chmod 700 "${USER_HOME_ROOT}/.ssh"

cat > .env <<EOF
USER_NAME=${USER_NAME_VALUE}
USER_UID=${USER_UID_VALUE}
USER_GID=${USER_GID_VALUE}
SSH_PORT=${SSH_PORT_VALUE}
APT_PACKAGES=${APT_PACKAGES_VALUE}
EOF

echo "Created .env for user ${USER_NAME_VALUE} (${USER_UID_VALUE}:${USER_GID_VALUE})."
echo "Ensured host directory root exists at ${DATA_ROOT}."