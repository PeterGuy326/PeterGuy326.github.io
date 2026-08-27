# dws-ch02 GIF 录制辅助函数 (bash, source 进来用)
# 给 vhs .tape 提供 Claude Code 风格的对话气泡 + 命令块视感

# 颜色 (ANSI)
C_USER=$'\033[1;36m'    # 青色加粗 = 你
C_CLAUDE=$'\033[1;33m'  # 黄色加粗 = Claude
C_DIM=$'\033[2;37m'     # 暗灰 = thinking
C_CMD=$'\033[1;32m'     # 绿色加粗 = $ command
C_OUT=$'\033[0;37m'     # 浅灰 = command output
C_WARN=$'\033[1;31m'    # 红色加粗 = 确认提示
C_RESET=$'\033[0m'

user_say()     { printf '\n%s▶ 你:%s %s\n' "$C_USER" "$C_RESET" "$1"; }
claude_think() { printf '%s  · %s%s\n' "$C_DIM" "$1" "$C_RESET"; }
claude_say()   { printf '%s● Claude:%s %s\n' "$C_CLAUDE" "$C_RESET" "$1"; }
claude_cont()  { printf '          %s\n' "$1"; }
cmd_run()      { printf '\n%s$ %s%s\n' "$C_CMD" "$1" "$C_RESET"; }
out()          { printf '%s%s%s\n' "$C_OUT" "$1" "$C_RESET"; }
warn()         { printf '%s⚠ %s%s\n' "$C_WARN" "$1" "$C_RESET"; }

# 想换成真 dws 命令:
#   dws_real() { eval "dws $1"; }
# 然后把 .tape 里的 cmd_run + out 两步合并成 dws_real "..."
