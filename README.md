# Shadowsocks Installer for Ubuntu

A modular, secure, and interactive Bash script to install and configure a [Shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev) server on Ubuntu. Designed for personal use and open-source contribution.

---

## Features

- Interactive password prompt with fallback to config
- CLI flags for automation (`--password`, `--port`, `--method`, `--config`)
- Dry-run mode (`--dry-run`) to preview actions
- Password strength validation
- UFW-aware firewall configuration
- Modular functions for maintainability
- Logging levels with color-coded output
- Auto-detects public IP for verification
- GitHub Actions CI with ShellCheck and auto-release

---

## Installation

Clone the repo and run the installer:

```bash
git clone https://github.com/ZeeshanJan/shadowsocks-installer.git
cd shadowsocks-installer
sudo ./install.sh
```

### Run interactively

```bash
sudo ./install.sh
```

### Run with CLI flags

```bash
sudo ./install.sh --password "MySecurePass123" --port 443 --method aes-256-gcm
```

### Run with a custom config file

```bash
sudo ./install.sh --config /path/to/config.json
```

### Preview actions without applying changes

```bash
sudo ./install.sh --dry-run
```

### Using `config.json.template`

If you prefer to define your configuration manually, you can copy and edit the template:
```bash
cp config.json.template /etc/shadowsocks-libev/config.json
```

## File Structure
shadowsocks-installer/
├── install.sh               # Main installer script
├── config.json.template     # Sample config for manual use
├── LICENSE                  # MIT License
├── README.md                # This file
└── .github/workflows/ci.yml # GitHub Actions workflow
