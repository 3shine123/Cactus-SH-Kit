# Cactus-SH-Kit

This repository is a vibe-coded, GitHub-hosted collection of my personal source code, featuring terminal scripts and C-based utilities. It is primarily designed to ensure my private tools are safely backed up and synced across devices, while optimizing daily command-line efficiency (with shell scripts offering faster execution).

You can seamlessly integrate these utilities into your own shell configuration file to run on terminal startup, trigger via aliases, or invoke as custom functions.

## 📦 Core Utilities

* **welcome&status**: A script that displays a welcome message and basic system status information. While its functionality overlaps with various existing `fetch` tools, it provides a lighter and more tailored alternative for daily use.
* **shorts&funcs**: Features the `hp` command, which allows you to quickly inspect custom aliases and functions defined within your `~/.zshrc`, `~/.bashrc`, or `~/.profile`.

## 📷 Screenshots

<img title="" src="./screenshots/截屏2026-06-14%2000.15.18.png" alt="截屏2026-06-14 00.15.18.png" width="516">

![截屏2026-06-14 00.15.32.png](./screenshots/截屏2026-06-14%2000.15.32.png)

## ⚙️ Installation & Configuration

### 1. Base Installation

Run the installation script to deploy the utilities to your `/usr/local/share/` directory:

```bash
sudo ./install.sh
```

### 2. Shell Integration

Depending on your personal workflow and preferences, you can integrate these tools into your shell configuration file using one of the following methods:

- **Manual Trigger (Alias)**: Set up a custom `alias` to launch the tools manually when needed.

- **Auto-start**: Add `. ~/xxx.sh` (or `source ~/xxx.sh`) to your shell configuration file to execute them automatically whenever a new terminal session is opened.

- **Custom Function**: Wrap the script logic into a dedicated shell function so you can execute it instantly by typing your custom command.

> 💡 **Future Plans**: This project is actively maintained for personal use. New features, enhancements, and updates will be continuously rolled out as inspiration and practical needs arise.
