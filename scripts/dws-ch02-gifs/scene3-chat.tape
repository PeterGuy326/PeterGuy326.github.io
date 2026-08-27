# 场景三: 一句话发群通知 (写操作,先确认再发)
# 输出: source/img/dws-ch02/scene3-chat.gif

Output ../../source/img/dws-ch02/scene3-chat.gif

Set Shell "bash"
Set FontSize 16
Set Width 1280
Set Height 720
Set Theme "Catppuccin Mocha"
Set TypingSpeed 25ms
Set Padding 20

Hide
Type "source ./prelude.sh && clear"
Enter
Show
Sleep 500ms

# === 用户提问 ===
Hide
Type `user_say "在「dws 专题讨论群」发个通知:今晚 10 点发布 Ch.2,大家留意。"`
Enter
Show
Sleep 1500ms

# === 步骤 1: 按名字搜群 ===
Hide
Type `claude_think "发群消息要 openConversationId,先按名字搜"`
Enter
Show
Sleep 700ms

Hide
Type `cmd_run "dws chat search --query 'dws 专题讨论' --format json"`
Enter
Show
Sleep 700ms

Hide
Type `out '[{"name":"dws 专题讨论群","openConversationId":"cidXXXXXXXX==","memberCount":48}]'`
Enter
Show
Sleep 1500ms

# === 步骤 2: 摆出来等确认 (写操作不闷头跑) ===
Hide
Type `claude_say "准备发送下面这条群消息,确认?"`
Enter
Show
Sleep 500ms

Hide
Type `claude_cont "  群:    dws 专题讨论群 (48 人)"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  标题:  📢 发布通知"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  正文:  今晚 22:00 发布 dws 专题 Ch.2,大家留意。"`
Enter
Show
Sleep 1500ms

# === 用户确认 ===
Hide
Type `user_say "确认"`
Enter
Show
Sleep 1000ms

# === 步骤 3: 真发 ===
Hide
Type `cmd_run "dws chat message send --group cidXXXXXXXX== --title '📢 发布通知' --text '今晚 22:00 发布 dws 专题 Ch.2,大家留意。' --format json"`
Enter
Show
Sleep 1000ms

Hide
Type `out '{"success":true,"messageId":"msg_20260523_2200_001"}'`
Enter
Show
Sleep 800ms

Hide
Type `claude_say "已发送 ✓"`
Enter
Show
Sleep 3000ms
