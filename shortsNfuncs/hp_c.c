#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAX_LEN 4096
#define FUNC_MAX 50
#define CASE_MAX 100

// 去除字符串两端的空格和换行
void trim(char *str) {
    int len = strlen(str);
    while (len > 0 && (str[len - 1] == ' ' || str[len - 1] == '\t' || str[len - 1] == '\n' || str[len - 1] == '\r')) {
        str[--len] = '\0';
    }
    int start = 0;
    while (str[start] == ' ' || str[start] == '\t') start++;
    if (start > 0) memmove(str, str + start, len - start + 1);
}

// 压缩多个空格为单个空格
void compress_spaces(char *str) {
    int i = 0, j = 0;
    int prev_space = 0;
    while (str[i]) {
        if (str[i] == ' ' || str[i] == '\t') {
            if (!prev_space) {
                str[j++] = ' ';
                prev_space = 1;
            }
        } else {
            str[j++] = str[i];
            prev_space = 0;
        }
        i++;
    }
    str[j] = '\0';
}

// 前置声明
void process_case_branch(const char *func_name, const char *line);
void process_function_definition(const char *func_name);

// 使用 zsh 获取函数的 case 分支（多行处理版本）
void process_function_definition(const char *func_name) {
    char cmd[512];
    snprintf(cmd, sizeof(cmd), "zsh -i -c 'typeset -f %s' 2>/dev/null", func_name);
    
    FILE *pipe = popen(cmd, "r");
    if (!pipe) return;
    
    char line[LINE_MAX_LEN];
    char accumulated[LINE_MAX_LEN * 2] = {0};  // 累积当前 case 分支
    int in_case_branch = 0;
    
    while (fgets(line, sizeof(line), pipe)) {
        // 检查是否是新的 case 分支开始：形如 "    (se)" 或 "        (cl)"
        char trimmed[LINE_MAX_LEN];
        strcpy(trimmed, line);
        
        // 提取缩进后的内容
        int indent = 0;
        while (trimmed[indent] == ' ' || trimmed[indent] == '\t') indent++;
        
        char *content = trimmed + indent;
        
        // 检查是否以 '(' 开头且后面有 ')' 
        if (content[0] == '(' && strchr(content, ')')) {
            // 先输出之前累积的分支（如果有）
            if (accumulated[0] != '\0') {
                // 处理和输出之前累积的内容
                process_case_branch(func_name, accumulated);
            }
            
            // 开始新的分支
            accumulated[0] = '\0';
            strcpy(accumulated, content);
            in_case_branch = 1;
        } else if (in_case_branch && strstr(line, ";;")) {
            // 分支结束
            strcat(accumulated, " ");
            strcat(accumulated, content);
            process_case_branch(func_name, accumulated);
            accumulated[0] = '\0';
            in_case_branch = 0;
        } else if (in_case_branch && strlen(content) > 0 && content[0] != 'e' && content[0] != '*') {
            // 分支内容继续
            strcat(accumulated, " ");
            strcat(accumulated, content);
        }
    }
    
    pclose(pipe);
}

// 处理单个 case 分支
void process_case_branch(const char *func_name, const char *line) {
    char copy[LINE_MAX_LEN];
    strcpy(copy, line);
    trim(copy);
    
    // 提取缩写（在第一个 ')' 之前，去掉括号）
    if (copy[0] != '(') return;
    
    char *end_paren = strchr(copy + 1, ')');
    if (!end_paren) return;
    
    char abbr[128];
    strncpy(abbr, copy + 1, end_paren - copy - 1);
    abbr[end_paren - copy - 1] = '\0';
    
    // 提取命令部分（在 ')' 之后，在 ';;' 之前）
    char cmd_part[LINE_MAX_LEN];
    strcpy(cmd_part, end_paren + 1);
    
    // 移除 ;;
    char *semi = strstr(cmd_part, ";;");
    if (semi) *semi = '\0';
    
    // 把换行符替换成空格
    for (int i = 0; cmd_part[i]; i++) {
        if (cmd_part[i] == '\n') cmd_part[i] = ' ';
    }
    
    trim(cmd_part);
    compress_spaces(cmd_part);
    
    // 提取注释
    char note[512] = "无描述";
    char *comment = strchr(cmd_part, '#');
    if (comment) {
        strcpy(note, comment + 1);
        trim(note);
        *comment = '\0';
        trim(cmd_part);
    }
    
    // 只显示有有效缩写的分支
    if (strlen(abbr) > 0 && strlen(abbr) <= 5) {
        printf("  \033[1;33m%s %-6s\033[0m -> %s \033[0;36m(%s)\033[0m\n", func_name, abbr, cmd_part, note);
    }
}

int main() {
    printf("\033[1;34m=== 💡 MY CUSTOM SHORTCUTS ===\033[0m\n");
    printf("\033[1;36m[ Global Aliases ]\033[0m\n");

    // ==========================================
    // 1. 别名提取：从交互式 zsh 获取
    // ==========================================
    FILE *pipe = popen("zsh -i -c 'alias' 2>/dev/null", "r");
    if (pipe) {
        char buffer[LINE_MAX_LEN];
        while (fgets(buffer, sizeof(buffer), pipe)) {
            trim(buffer);
            char *eq = strchr(buffer, '=');
            if (eq) {
                *eq = '\0';
                char *name = buffer;
                char *cmd = eq + 1;
                trim(name);
                trim(cmd);
                
                // 剥离 Zsh 自动加的外层单引号
                int clen = strlen(cmd);
                if (clen >= 2 && cmd[0] == '\'' && cmd[clen - 1] == '\'') {
                    cmd[clen - 1] = '\0';
                    cmd++;
                }
                
                // 只显示自定义的核心别名
                if (strcmp(name, "zshconfig") == 0 || strcmp(name, "ohmyzsh") == 0 || 
                    strcmp(name, "ff") == 0 || strcmp(name, "ls") == 0 || 
                    strcmp(name, "ll") == 0 || strcmp(name, "bls") == 0 || 
                    strcmp(name, "bll") == 0 || strcmp(name, "proxy") == 0 || 
                    strcmp(name, "unproxy") == 0) {
                    printf("  \033[1;32m%-12s\033[0m -> %s\n", name, cmd);
                }
            }
        }
        pclose(pipe);
    }

    printf("\n");

    // ==========================================
    // 2. 函数提取：从交互式 zsh 获取函数列表
    // ==========================================
    pipe = popen("zsh -i -c 'typeset +f' 2>/dev/null | grep -E '^(br|mk)$'", "r");
    if (pipe) {
        char func_name[128];
        while (fgets(func_name, sizeof(func_name), pipe)) {
            trim(func_name);
            if (strlen(func_name) == 0) continue;
            
            // 排除 hp 本身
            if (strcmp(func_name, "hp") == 0) continue;
            
            printf("\033[1;36m[ Function: %s ]\033[0m\n", func_name);
            
            // 处理该函数的 case 分支
            process_function_definition(func_name);
            
            printf("\n");
        }
        pclose(pipe);
    }

    printf("\033[1;34m==============================\033[0m\n");
    return 0;
}