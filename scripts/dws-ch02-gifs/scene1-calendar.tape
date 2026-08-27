# 场景一: 一句话查今日日程
# 输出: source/img/dws-ch02/scene1-calendar.gif

Output ../../source/img/dws-ch02/scene1-calendar.gif

Set Shell "bash"
Set FontSize 16
Set Width 1200
Set Height 640
Set Theme "Catppuccin Mocha"
Set TypingSpeed 25ms
Set Padding 20

# === 启动:加载对话气泡函数,清屏 ===
Hide
Type "source ./prelude.sh && clear"
Enter
Show
Sleep 500ms

# === 用户提问 ===
Hide
Type `user_say "我今天有什么安排?"`
Enter
Show
Sleep 1500ms

# === Claude 的 reasoning ===
Hide
Type `claude_think "翻 skill 决策树 → 'calendar' 产品"`
Enter
Show
Sleep 700ms

Hide
Type `claude_think "calendar event list 需要 --start / --end (ISO-8601)"`
Enter
Show
Sleep 700ms

Hide
Type `claude_think "算今天的时间窗 00:00–23:59,带 +08:00"`
Enter
Show
Sleep 800ms

# === Claude 跑的命令 ===
Hide
Type `cmd_run "dws calendar event list --start 2026-05-23T00:00:00+08:00 --end 2026-05-23T23:59:59+08:00 --format json --jq '.result.events'"`
Enter
Show
Sleep 600ms

# === 命令输出 (mock; 想换真数据见 README) ===
Hide
Type `out '[{"summary":"晨会站会","start":"09:30","end":"10:00"},{"summary":"dws Ch.2 内审","start":"14:00","end":"15:00"},{"summary":"和开放平台对齐","start":"16:30","end":"17:30"}]'`
Enter
Show
Sleep 1500ms

# === Claude 整理后的回复 ===
Hide
Type `claude_say "你今天 3 个安排:"`
Enter
Show
Sleep 400ms

Hide
Type `claude_cont "  09:30–10:00  晨会站会"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  14:00–15:00  dws Ch.2 内审"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  16:30–17:30  和开放平台对齐"`
Enter
Show
Sleep 3000ms
