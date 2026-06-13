#!/bin/bash

# 1. 动态获取当前脚本所在的绝对路径和项目名
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_NAME=$(basename "$SCRIPT_DIR")

# 2. 定义统一的系统安装路径
INSTALL_DATA_DIR="/usr/local/share/$PROJECT_NAME"

# 3. 检测终端语言环境
if [[ "$LANG" == *zh* ]]; then
    IS_CHINESE=true
else
    IS_CHINESE=false
fi

# 4. 安全锁：防止在安装目录下重复自杀式运行
if [ "$SCRIPT_DIR" = "$INSTALL_DATA_DIR" ]; then
    if [ "$IS_CHINESE" = true ]; then
        echo "提示: 项目已安装在系统目录中，无需重复安装。"
    else
        echo "Notice: Project is already installed in system directory."
    fi
    exit 0
fi

# 5. 打印准备提示
if [ "$IS_CHINESE" = true ]; then
    echo "正在准备将项目文件夹移至系统共享目录（可能需要输入 Mac 密码）..."
    echo "当前路径: $SCRIPT_DIR"
    echo "目标路径: $INSTALL_DATA_DIR"
else
    echo "Preparing to move project folder to system share directory (sudo password may be required)..."
    echo "Current path: $SCRIPT_DIR"
    echo "Target path: $INSTALL_DATA_DIR"
fi

# 6. 如果系统里有旧版，先清理
if [ -d "$INSTALL_DATA_DIR" ]; then
    if [ "$IS_CHINESE" = true ]; then
        echo "提示: 检测到已存在旧版本，正在覆盖..."
    else
        echo "Warning: Old version detected. Overwriting..."
    fi
    sudo rm -rf "$INSTALL_DATA_DIR"
fi

# 7. 核心步骤：将整个项目文件夹复制到 /usr/local/share/
sudo cp -r "$SCRIPT_DIR" "/usr/local/share/"

# 8. 打印安装成功提示
if [ "$IS_CHINESE" = true ]; then
    echo "安装成功!"
    echo "整个项目文件夹已安全存放到: $INSTALL_DATA_DIR"
else
    echo "Installation successful!"
    echo "The entire project folder has been moved to: $INSTALL_DATA_DIR"
fi
