#!/bin/bash
# Shadowsocks-libev Installer for Ubuntu
# Author: Zeeshan Jan
# License: MIT

set -e

# === Defaults ===
DEFAULT_PORT=8388
DEFAULT_METHOD="chacha20-ietf-poly1305"
CONFIG_PATH="/etc/shadowsocks-libev/config.json"

# === Functions ===

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
  fi
}

install_dependencies() {
  echo "Installing dependencies..."
  apt update && apt install -y shadowsocks-libev jq curl
}

prompt_user_input() {
  read -s -p "Enter Shadowsocks password: " SS_PASSWORD
  echo
  read -p "Enter server port [default: $DEFAULT_PORT]: " SS_PORT
  SS_PORT=${SS_PORT:-$DEFAULT_PORT}
  read -p "Enter encryption method [default: $DEFAULT_METHOD]: " SS_METHOD
  SS_METHOD=${SS_METHOD:-$DEFAULT_METHOD}
}

validate_inputs() {
  [[ "$SS_PORT" =~ ^[0-9]+$ ]] || { echo "Invalid port"; exit 1; }
}

generate_config() {
  echo "Generating config at $CONFIG_PATH..."
  mkdir -p "$(dirname "$CONFIG_PATH")"
  tee "$CONFIG_PATH" > /dev/null <<EOF
{
  "server": ["::1", "0.0.0.0"],
  "mode": "tcp_and_udp",
  "server_port": $SS_PORT,
  "local_port": 1080,
  "password": "$SS_PASSWORD",
  "timeout": 86400,
  "method": "$SS_METHOD"
}
EOF
}

configure_firewall() {
  if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
    echo "UFW is active — opening ports..."
    ufw allow "$SS_PORT"/tcp
    ufw allow "$SS_PORT"/udp
  else
    echo "UFW inactive or not installed — skipping firewall rules."
  fi
}

start_service() {
  echo "Restarting Shadowsocks service..."
  systemctl restart shadowsocks-libev
  systemctl enable shadowsocks-libev
}

print_summary() {
  SERVER_IP=$(curl -s https://api.ipify.org)
  echo "Shadowsocks server is running!"
  echo "Server IP: $SERVER_IP"
  echo "Port: $SS_PORT"
  echo "Method: $SS_METHOD"
}

# === Main Execution ===
check_root
install_dependencies
prompt_user_input
validate_inputs
generate_config
configure_firewall
start_service
print_summary
