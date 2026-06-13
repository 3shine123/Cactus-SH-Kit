# Cactus-SH-Kit

This repository serves as a GitHub-hosted backup of my personal source code, featuring terminal scripts and C-based utilities developed with Vibe Code. It is primarily designed to optimize command-line efficiency (with shell scripts offering faster execution) while ensuring my private tools are safely backed up and synced across devices. 

You can seamlessly integrate these utilities into your own shell configuration file to run on terminal startup, trigger via aliases, or invoke as custom functions.

## 📦 Core Utilities

* **welcome&status**: A script that displays a welcome message and basic system status information. While its functionality overlaps with various existing `fetch` tools, it provides a lighter and more tailored alternative for daily use.
* **shorts&funcs**: Features the `hp` command, which allows you to quickly inspect custom aliases and functions defined within your `~/.zshrc`, `~/.bashrc`, or `~/.profile`.

## ⚙️ Installation & Configuration

### 1. Base Installation

Run the installation script to deploy the utilities to your user home directory (`~/`):

```bash
./install.sh
```




### 2. Shell Integration

Depending on your personal workflow and preferences, you can integrate these tools into your shell configuration file using one of the following methods:

- **Manual Trigger (Alias)**: Set up a custom `alias` to launch the tools manually when needed.

- **Auto-start**: Add `. ~/xxx.sh` (or `source ~/xxx.sh`) to your configuration file to execute them automatically whenever a new terminal session is opened.

- **Custom Function**: Wrap the script logic into a dedicated shell function so you can execute it instantly by typing your custom command.

> 💡 **Future Plans**: This project is actively maintained for personal use. New features, enhancements, and updates will be continuously rolled out as inspiration and practical needs arise.
