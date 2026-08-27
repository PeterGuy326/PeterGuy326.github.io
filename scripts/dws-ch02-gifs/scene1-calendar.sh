#!/usr/bin/env bash
# scene1-calendar 的 asciinema+agg 录制驱动
# 用法: 由 Makefile (make all-agg) 调用,不直接跑
source "$(dirname "$0")/prelude.sh"
sleep 0.4

user_say "我今天有什么安排?"
sleep 1.2

claude_think "翻 skill 决策树 → 'calendar' 产品"
sleep 0.6
claude_think "calendar event list 需要 --start / --end (ISO-8601)"
sleep 0.6
claude_think "算今天的时间窗 00:00–23:59,带 +08:00"
sleep 0.7

cmd_run "dws calendar event list --start 2026-05-23T00:00:00+08:00 --end 2026-05-23T23:59:59+08:00 --format json --jq '.result.events'"
sleep 0.5
out '[{"summary":"晨会站会","start":"09:30","end":"10:00"},{"summary":"dws Ch.2 内审","start":"14:00","end":"15:00"},{"summary":"和开放平台对齐","start":"16:30","end":"17:30"}]'
sleep 1.3

claude_say "你今天 3 个安排:"
sleep 0.35
claude_cont "  09:30-10:00  晨会站会"
sleep 0.3
claude_cont "  14:00-15:00  dws Ch.2 内审"
sleep 0.3
claude_cont "  16:30-17:30  和开放平台对齐"
sleep 2.5
