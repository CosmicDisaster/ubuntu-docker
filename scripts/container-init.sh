#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${USER_NAME:-devuser}"
USER_HOME="/home/${USER_NAME}"
USER_SSH_DIR="${USER_HOME}/.ssh"
AUTHORIZED_KEYS_TARGET="${USER_SSH_DIR}/authorized_keys"

mkdir -p /var/run/sshd "${USER_SSH_DIR}"
chmod 700 "${USER_SSH_DIR}"

# Prefer a repo-scoped key file when mounted with the workspace.
if [[ -f /workspace/.ssh/authorized_keys ]]; then
  cp /workspace/.ssh/authorized_keys "${AUTHORIZED_KEYS_TARGET}"
fi

# Fall back to a compose-mounted key file.
if [[ -f /tmp/authorized_keys ]]; then
  cp /tmp/authorized_keys "${AUTHORIZED_KEYS_TARGET}"
fi

if [[ -f "${AUTHORIZED_KEYS_TARGET}" ]]; then
  chown "${USER_NAME}:${USER_NAME}" "${AUTHORIZED_KEYS_TARGET}"
  chmod 600 "${AUTHORIZED_KEYS_TARGET}"
fi

# Ensure host keys exist even in fresh containers.
ssh-keygen -A >/dev/null 2>&1 || true

exec /usr/sbin/sshd -D -e