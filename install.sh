#!/bin/bash
# Shadowsocks-libev Installer for Ubuntu
# Author: Zeeshan Jan
# License: MIT

set -e

# === Logging Functions ===
log_info()    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_warn()    { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error()   { echo -e "\033[1;31m[ERROR]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }

# === Defaults ===
DEFAULT_PORT=8388
DEFAULT_METHOD="chacha20-ietf-poly1305"
DEFAULT_CONFIG="/etc/shadowsocks-libev/config.json"
DRY_RUN=false

# === Globals ===
SS_PORT=""
SS_METHOD=""
SS_PASSWORD=""
CONFIG_PATH=""

# === Parse CLI Flags ===
parse_flags() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --password) SS_PASSWORD="$2"; shift ;;
      --port) SS_PORT="$2"; shift ;;
      --method) SS_METHOD="$2"; shift ;;
      --config) CONFIG_PATH="$2"; shift ;;
      --dry-run) DRY_RUN=true ;;
      *) log_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
  done
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root (use sudo)"
    exit 1
  fi
}

load_config_fallback() {
  CONFIG_PATH="${CONFIG_PATH:-$DEFAULT_CONFIG}"
  SS_PORT="${SS_PORT:-$DEFAULT_PORT}"
  SS_METHOD="${SS_METHOD:-$DEFAULT_METHOD}"

  if [ -z "$SS_PASSWORD" ] && [ -f "$CONFIG_PATH" ]; then
    log_info "Loading password from $CONFIG_PATH"
    SS_PASSWORD=$(jq -r '.password' "$CONFIG_PATH")
  fi
}

prompt_user_input() {
  if [ -z "$SS_PASSWORD" ]; then
    read -s -p "Enter Shadowsocks password: " SS_PASSWORD
    echo
  fi
}

validate_password_strength() {
  if [[ ${#SS_PASSWORD} -lt 8 ]] || ! [[ "$SS_PASSWORD" =~ [A-Z] ]] || ! [[ "$SS_PASSWORD" =~ [0-9] ]]; then
    log_warn "Password appears weak (less than 8 chars, lacks uppercase or digits)"
  fi
}

validate_inputs() {
  [[ "$SS_PORT" =~ ^[0-9]+$ ]] || { log_error "Invalid port"; exit 1; }
}

dry_run_summary() {
  log_info "Dry run enabled — no changes will be made"
  echo "Would install: shadowsocks-libev jq curl"
  echo "Would write config to: $CONFIG_PATH"
  echo "Would open UFW ports: $SS_PORT/tcp and $SS_PORT/udp"
  echo "Would restart: shadowsocks-libev"
  exit 0
}

install_dependencies() {
  log_info "Installing dependencies..."
  apt update && apt install -y shadowsocks-libev jq curl
}

generate_config() {
  log_info "Writing config to $CONFIG_PATH"
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
    log_info "UFW is active — opening ports..."
    ufw allow "$SS_PORT"/tcp
    ufw allow "$SS_PORT"/udp
  else
    log_warn "UFW inactive or not installed — skipping firewall rules"
  fi
}

start_service() {
  log_info "Restarting Shadowsocks service..."
  systemctl restart shadowsocks-libev
  systemctl enable shadowsocks-libev
}

print_summary() {
  SERVER_IP=$(curl -s https://api.ipify.org)
  log_success "Shadowsocks server is running!"
  echo "Server IP: $SERVER_IP"
  echo "Port: $SS_PORT"
  echo "Method: $SS_METHOD"
}

# === Main Execution ===
parse_flags "$@"
check_root
load_config_fallback
prompt_user_input
validate_password_strength
validate_inputs
$DRY_RUN && dry_run_summary
install_dependencies
generate_config
configure_firewall
start_service
print_summary
