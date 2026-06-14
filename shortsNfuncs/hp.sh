#!/bin/bash

# hp - Cactus 的跨平台动态快捷键备忘录

# 1. 自动根据当前 Shell 匹配对应的配置文件
case "$(basename "$SHELL")" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)    RC_FILE="$HOME/.profile" ;; # 兜底
esac

printf "\n\033[1;34m=== MY CUSTOM SHELL SHORTCUTS [$(basename "$SHELL")] ===\033[0m\n"

# ==========================================
# 1. 动态抓取当前处于激活状态的别名 (Alias)
# ==========================================
printf "\033[1;36m[ Aliases ]\033[0m\n"
if [ -f "$RC_FILE" ]; then
    grep -E "^alias " "$RC_FILE" | sed 's/^alias //g' | while read -r line; do
        name=$(echo "$line" | cut -d'=' -f1)
        cmd=$(echo "$line" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
        printf "  \033[1;32m%-12s\033[0m -> %s\n" "$name" "$cmd"
    done
fi

printf "\n"

# ==========================================
# 2. 标准化通用函数分支解析 (Functions)
# ==========================================
# 匹配所有形式为 `name() {` 的自定义函数
if [ -f "$RC_FILE" ]; then
    grep -E "^[a-zA-Z0-9_-]+\(\)\s*\{" "$RC_FILE" | tr -d '(){ ' | while read -r func_name; do
        # 排除 hp 脚本自身
        [ "$func_name" = "hp" ] && continue

        # 截取该函数的完整函数体
        func_body=$(sed -n "/^${func_name}()/,/^}/p" "$RC_FILE")
        
        # 过滤：函数体内必须包含 case 分支语句，否则跳过
        echo "$func_body" | grep -q "case " || continue
        
        printf "\033[1;36m[ Function: %s ]\033[0m\n" "$func_name"
        
        last_comment=""
        echo "$func_body" | while read -r line; do
            # 去除行首和行尾的空格/制表符
            clean_line=$(echo "$line" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

            # 如果是以 # 开头的独立注释行，记录下来并继续循环
            if [[ "$clean_line" =~ ^# ]]; then
                last_comment=$(echo "$clean_line" | sed 's/^#[ \t]*//')
                continue
            fi

            # 匹配 case 内部的分支行，如 `abbr)`
            if [[ "$clean_line" =~ ^[a-zA-Z0-9_*?-]+\) ]]; then
                abbr=$(echo "$clean_line" | cut -d')' -f1 | tr -d ' ')
                cmd_part=$(echo "$clean_line" | cut -d')' -f2- | sed 's/;;.*//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
                inline_comment=$(echo "$clean_line" | sed -n 's/.*#[ \t]*//p')
                
                # 默认无描述文本
                final_note="No description"
                if [ -n "$inline_comment" ]; then
                    # 优先使用行内尾随注释
                    final_note="$inline_comment"
                    cmd_part=$(echo "$cmd_part" | sed 's/\s*#.*//')
                elif [ -n "$last_comment" ]; then
                    # 其次使用上一行的独立注释
                    final_note="$last_comment"
                fi

                # 如果执行命令部分为空，说明后面跟了多行复杂逻辑
                if [ -z "$cmd_part" ]; then
                    cmd_part="Executing multi-line logic..."
                fi
                printf "  \033[1;33m%s %-6s\033[0m -> %s \033[0;36m(%s)\033[0m\n" "$func_name" "$abbr" "$cmd_part" "$final_note"
                
                last_comment=""
            else
                # 清除状态机残留的上一行注释，防止非 case 分支行误用
                [[ -n "$clean_line" && "$clean_line" != "case"* && "$clean_line" != "esac"* ]] && last_comment=""
            fi
        done
        printf "\n"
    done
fi

# ==========================================
# 3. 解析系统环境变量 PATH
# ==========================================
printf "\n\033[1;36m[ System PATH ]\033[0m\n"

count=1
# 将冒号分隔的 PATH 字符串转换为换行，并逐行读取
echo "$PATH" | tr ':' '\n' | while read -r path_dir; do
    # 跳过空路径
    [ -z "$path_dir" ] && continue
    
    # 检查路径在当前系统是否存在
    if [ -d "$path_dir" ]; then
        # 正常路径：绿字序号 -> 路径
        printf "  \033[1;32m[%02d]\033[0m %s\n" "$count" "$path_dir"
    else
        # 失效路径：红字序号 -> 路径并标注 (Not Found/Dead)
        printf "  \033[1;31m[%02d]\033[0m %s \033[0;31m(Not Found/Dead)\033[0m\n" "$count" "$path_dir"
    fi
    ((count++))
done

printf "\n"

printf "\033[1;34m=======================================\033[0m\n"