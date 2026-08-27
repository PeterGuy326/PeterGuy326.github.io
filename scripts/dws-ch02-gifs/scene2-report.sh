#!/usr/bin/env bash
# scene2-report 的 asciinema+agg 录制驱动
source "$(dirname "$0")/prelude.sh"
sleep 0.4

user_say "把我这周做完的待办,整理成周报发出去。"
sleep 1.3

claude_think "拆解: 待办(todo) + 日志(report) 跨产品"
sleep 0.7

claude_think "① 先拉已完成待办,按完成时间挑本周"
sleep 0.4
cmd_run "dws todo task list --status true --format json --jq '.result.tasks[] | select(.finishTime > 1747958400000)'"
sleep 0.7
out '[{"subject":"修完登录页 3 个 bug","finishTime":1748044800000},{"subject":"上线 dws 专题 Ch.1","finishTime":1748131200000}]'
sleep 1.3

claude_think "② 钉钉日志模板驱动,先查有哪些模板"
sleep 0.4
cmd_run "dws report template list --format json --jq '.result.templates[] | {name,templateId}'"
sleep 0.7
out '[{"name":"周报","templateId":"tpl_zhoubao_001"},{"name":"日报","templateId":"tpl_ribao_002"}]'
sleep 1.1

claude_think "③ 拉周报模板的字段定义 (key/sort/type)"
sleep 0.4
cmd_run "dws report template detail --name '周报' --format json"
sleep 0.7
out '{"fields":[{"key":"本周完成","sort":"0","type":"1"},{"key":"下周计划","sort":"1","type":"1"}]}'
sleep 1.1

claude_say "周报内容拟好了,确认发吗?"
sleep 0.5
claude_cont "  [本周完成]"
sleep 0.2
claude_cont "    - 修完登录页 3 个 bug"
sleep 0.2
claude_cont "    - 上线 dws 专题 Ch.1"
sleep 0.3
claude_cont "  [下周计划]"
sleep 0.2
claude_cont "    - 写 dws 专题 Ch.3"
sleep 1.3

user_say "发"
sleep 1.0

cmd_run "dws report create --template-id tpl_zhoubao_001 --contents '[...]' --format json"
sleep 0.9
out '{"success":true,"reportId":"rpt_20260523_001"}'
sleep 0.7
claude_say "已提交 OK  报告 ID: rpt_20260523_001"
sleep 2.5
