# Shadowsocks Installer for Ubuntu

A modular, secure, and interactive Bash script to install and configure a [Shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev) server on Ubuntu. Designed for personal use.

---

## Features

- Interactive password prompt (hidden input)
- Smart defaults for port and encryption method
- Input validation for security and reliability
- Auto-detects public IP for quick verification
- UFW-aware firewall configuration
- Modular functions for easy extension
- CI workflow with ShellCheck linting and auto-release
- Ready for plugin support and QR code generation (future roadmap)

---

## Installation

Clone the repo and run the installer:

```bash
git clone https://github.com/yourusername/shadowsocks-installer.git
cd shadowsocks-installer
sudo ./install.sh
