#!/bin/bash

# hp - Cactus 的跨平台动态快捷键备忘录

# 1. 自动定位当前的 RC 配置文件
case "$(basename "$SHELL")" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)    RC_FILE="$HOME/.profile" ;; # 兜底
esac

printf "\n\033[1;34m=== MY CUSTOM SHELL SHORTCUTS [$(basename "$SHELL")] ===\033[0m\n"

# ==========================================
# 1. 动态抓取所有活着的别名 (Alias)
# ==========================================
printf "\n\033[1;36m[ Aliases ]\033[0m\n"
grep -E "^alias " "$RC_FILE" | sed 's/^alias //g' | while read -r line; do
    name=$(echo "$line" | cut -d'=' -f1)
    cmd=$(echo "$line" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    printf "  \033[1;32m%-12s\033[0m -> %s\n" "$name" "$cmd"
done

printf "\n"

# ==========================================
# 2. 标准化通用函数分支解析 (Functions)
# ==========================================
# 找出所有形式为 `name() {` 的函数
grep -E "^[a-zA-Z0-9_-]+\(\)\s*\{" "$RC_FILE" | tr -d '(){ ' | while read -r func_name; do
    # 排除自身
    [ "$func_name" = "hp" ] && continue

    # 提取完整函数体
    func_body=$(sed -n "/^${func_name}()/,/^}/p" "$RC_FILE")
    
    # 过滤：必须包含 case 分支
    echo "$func_body" | grep -q "case " || continue
    
    printf "\033[1;36m[ Function: %s ]\033[0m\n" "$func_name"
    
    last_comment=""
    echo "$func_body" | while read -r line; do
        clean_line=$(echo "$line" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

        if [[ "$clean_line" =~ ^# ]]; then
            last_comment=$(echo "$clean_line" | sed 's/^#[ \t]*//')
            continue
        fi

        if [[ "$clean_line" =~ ^[a-zA-Z0-9_*?-]+\) ]]; then
            abbr=$(echo "$clean_line" | cut -d')' -f1 | tr -d ' ')
            cmd_part=$(echo "$clean_line" | cut -d')' -f2- | sed 's/;;.*//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
            inline_comment=$(echo "$clean_line" | sed -n 's/.*#[ \t]*//p')
            
            final_note="无描述"
            if [ -n "$inline_comment" ]; then
                final_note="$inline_comment"
                cmd_part=$(echo "$cmd_part" | sed 's/\s*#.*//')
            elif [ -n "$last_comment" ]; then
                final_note="$last_comment"
            fi

            [ -z "$cmd_part" ] && cmd_part="执行后续多行复合逻辑..."
            printf "  \033[1;33m%s %-6s\033[0m -> %s \033[0;36m(%s)\033[0m\n" "$func_name" "$abbr" "$cmd_part" "$final_note"
            
            last_comment=""
        else
            # 清理状态机残留
            [[ -n "$clean_line" && "$clean_line" != "case"* && "$clean_line" != "esac"* ]] && last_comment=""
        fi
    done
    printf "\n"
done

printf "\033[1;34m=======================================\033[0m\n"