#!/usr/bin/env bash
# scene3-chat 的 asciinema+agg 录制驱动
source "$(dirname "$0")/prelude.sh"
sleep 0.4

user_say "在「dws 专题讨论群」发个通知:今晚 10 点发布 Ch.2,大家留意。"
sleep 1.3

claude_think "发群消息要 openConversationId,先按名字搜"
sleep 0.6
cmd_run "dws chat search --query 'dws 专题讨论' --format json"
sleep 0.6
out '[{"name":"dws 专题讨论群","openConversationId":"cidXXXXXXXX==","memberCount":48}]'
sleep 1.3

claude_say "准备发送下面这条群消息,确认?"
sleep 0.4
claude_cont "  群:    dws 专题讨论群 (48 人)"
sleep 0.3
claude_cont "  标题:  发布通知"
sleep 0.3
claude_cont "  正文:  今晚 22:00 发布 dws 专题 Ch.2,大家留意。"
sleep 1.3

user_say "确认"
sleep 0.9

cmd_run "dws chat message send --group cidXXXXXXXX== --title '发布通知' --text '今晚 22:00 发布 dws 专题 Ch.2,大家留意。' --format json"
sleep 0.9
out '{"success":true,"messageId":"msg_20260523_2200_001"}'
sleep 0.7
claude_say "已发送 OK"
sleep 2.5
