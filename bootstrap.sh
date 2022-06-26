#! /bin/bash
set -o errexit

# Usage:
# ./bootstrap.sh <node_name> [<server_node_ip> <k3s_token>]
# k3s token can be found at /var/lib/rancher/k3s/server/node-token

create_ubuntu_user () {
  if id -u ubuntu >/dev/null 2>&1; then
    echo "ubuntu user exists, deleting..."
    killall -u ubuntu
    deluser --remove-home ubuntu
  fi

  useradd --create-home --comment Ubuntu --user-group -s /bin/bash --groups "adm,dialout,cdrom,floppy,sudo,audio,dip,video,plugdev" ubuntu
  printf 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu

  mkdir -p /home/ubuntu/.ssh
  chmod 700 /home/ubuntu/.ssh
  cat /root/.ssh/authorized_keys > /home/ubuntu/.ssh/authorized_keys
  chmod 600 /home/ubuntu/.ssh/authorized_keys
  chown -R ubuntu:ubuntu /home/ubuntu/.ssh
}

disable_password_login () {
  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  sed -i 's/PubkeyAuthentication yes/PubkeyAuthentication no/g' /etc/ssh/sshd_config
  sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
  systemctl restart sshd
}

install_k3s () {
  local node_name k3s_installer
  node_name=$1
  k3s_installer="https://get.k3s.io"

  if [ -z "$node_name" ]; then
    echo "ERROR: node_name is required"
    exit 1
  fi

  if [ "$node_name" == master ]; then
    curl -sfL "${k3s_installer}" | sh -s - --disable traefik --node-name "${node_name}"
  fi
  
  local k3s_public_ip k3s_token
  k3s_public_ip=$2
  k3s_token=$3
  
  if [ -z "$k3s_public_ip" ] || [ -z "$k3s_token" ]; then
    echo "ERROR: k3s_public_ip and k3s_token are required when the node is not master"
    exit 1
  fi

  if [[ "$node_name" == agent-* ]]; then
    curl -sfL "${k3s_installer}" |
      K3S_URL="https://${k3s_public_ip}:6443" \
      K3S_TOKEN="${k3s_token}" \
      sh -s - --node-name "${node_name}"
  fi
}

main () {
  create_ubuntu_user
  disable_password_login
  install_k3s "$@"
}

main "$@"