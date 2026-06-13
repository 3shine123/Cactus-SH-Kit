#!/bin/bash

# =====================================================================
# 欢迎提示 & 智能自适应状态看板 (printf 跨 Shell 像素级终结版)
# =====================================================================

printf "\nWelcome to Terminal!\n\n"
printf "\033[1;34m=== SYSTEM STATUS ===\033[0m\n"

printf "User:        \033[1;32m%s\033[0m\n" "$USER"
printf "Hostname:    %s\n" "$(hostname)"

# 1. 动态智能识别操作系统与版本
if [ "$(uname)" = "Darwin" ]; then
    printf "OS Version:  \033[1;33mmacOS %s\033[0m\n" "$(sw_vers -productVersion)"
elif [ -f /etc/os-release ]; then
    os_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
    printf "OS Version:  \033[1;33m%s\033[0m\n" "$os_name"
else
    printf "OS Version:  %s %s\n" "$(uname -s)" "$(uname -r)"
fi

# 2. 动态识别当前 Shell 及其版本
if [ -n "$ZSH_VERSION" ]; then
    printf "Shell:       \033[1;32mzsh %s\033[0m\n" "$ZSH_VERSION"
elif [ -n "$BASH_VERSION" ]; then
    printf "Shell:       \033[1;32mbash %s\033[0m\n" "$BASH_VERSION"
else
    printf "Shell:       %s\n" "$(basename "$SHELL")"
fi

# 3. 跨平台自适应提取 Uptime 
if [ "$(uname)" = "Darwin" ]; then
    uptime_str=$(uptime | sed 's/.*up \([^,]*\), .*/\1/' | xargs)
else
    uptime_str=$(uptime -p 2>/dev/null | sed 's/^up //' || uptime | awk -F'(up|user)' '{print $2}' | cut -d',' -f1,2)
    uptime_str=$(echo "$uptime_str" | xargs)
fi
printf "Uptime:      %s\n" "$uptime_str"


# 4. 跨平台多包管理器数量动态侦测
pkg_info=""

if command -v brew &> /dev/null; then
    brew_cellar=$(brew --cellar 2>/dev/null)
    if [ -d "$brew_cellar" ]; then
        brew_count=$(ls -1 "$brew_cellar" 2>/dev/null | wc -l | tr -d ' ')
        pkg_info="${pkg_info}\033[1;36m${brew_count}\033[0m (Brew)  "
    fi
fi

if command -v dpkg &> /dev/null; then
    apt_count=$(dpkg-query -l 2>/dev/null | grep -c "^ii")
    [ "$apt_count" -gt 0 ] && pkg_info="${pkg_info}\033[1;36m${apt_count}\033[0m (APT)  "
fi

if command -v pacman &> /dev/null; then
    pacman_count=$(pacman -Q 2>/dev/null | wc -l | tr -d ' ')
    [ "$pacman_count" -gt 0 ] && pkg_info="${pkg_info}\033[1;36m${pacman_count}\033[0m (Pacman)  "
fi

# * 这里换用 %b 强制激活包管理器变量内部包裹的颜色代码
if [ -n "$pkg_info" ]; then
    printf "Packages:    %b\n" "$pkg_info"
else
    printf "Packages:    0 installed\n"
fi


# 5. 智能探测 Clang 编译器家族
if command -v clang &> /dev/null; then
    clang_ver_str=$(clang --version | head -n 1)
    if [[ "$clang_ver_str" == *"Apple"* ]]; then
        printf "Apple Clang: \033[1;31m%s\033[0m\n" "$clang_ver_str"
    else
        printf "Sys Clang:   \033[1;32m%s\033[0m\n" "$clang_ver_str"
    fi
else
    printf "Sys Clang:   Not Found\n"
fi

if command -v brclang &> /dev/null; then
    printf "Brew Clang:  \033[1;35m%s\033[0m\n" "$(brclang --version | head -n 1)"
fi

printf "\033[1;34m=====================\033[0m\n"