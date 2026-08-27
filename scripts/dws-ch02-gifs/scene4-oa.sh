#!/usr/bin/env bash
# scene4-oa 的 asciinema+agg 录制驱动
source "$(dirname "$0")/prelude.sh"
sleep 0.4

user_say "看看我有什么待审批的。"
sleep 1.3

claude_think "走 oa 产品的 list-pending"
sleep 0.5
cmd_run "dws oa approval list-pending --format json --jq '.result[] | {title,processInstanceId,submitter}'"
sleep 0.7
out '[{"title":"差旅报销 1280 元","processInstanceId":"piid_001","submitter":"李四"},'
out ' {"title":"采购申请 2 台显示器","processInstanceId":"piid_002","submitter":"王五"}]'
sleep 1.3

claude_say "2 单待你审:"
sleep 0.3
claude_cont "  1. 差旅报销 1280 元 (李四)"
sleep 0.3
claude_cont "  2. 采购申请 2 台显示器 (王五)"
sleep 1.3

user_say "第一个,看下内容,没问题就同意。"
sleep 1.3

claude_think "动手前先读详情 (skill 硬规矩)"
sleep 0.4
cmd_run "dws oa approval detail --instance-id piid_001 --format json"
sleep 0.7
out '{"title":"差旅报销","amount":1280,"reason":"上海客户拜访 2 天","attachments":["发票.pdf"]}'
sleep 1.3

claude_think "approve 要的是 taskId 不是 instanceId,必须中间再查一次"
sleep 0.7
cmd_run "dws oa approval tasks --instance-id piid_001 --format json --jq '.result[] | {taskId,userId}'"
sleep 0.6
out '[{"taskId":"tid_xyz","userId":"me"}]'
sleep 1.1

claude_say "准备同意,确认?"
sleep 0.4
claude_cont "  单据:    差旅报销 1280 元"
sleep 0.3
claude_cont "  申请人:  李四"
sleep 0.3
claude_cont "  事由:    上海客户拜访 2 天"
sleep 0.3
claude_cont "  附件:    发票.pdf"
sleep 1.3

user_say "同意"
sleep 0.9

cmd_run "dws oa approval approve --instance-id piid_001 --task-id tid_xyz --remark '同意,按流程推进' --format json"
sleep 0.9
out '{"success":true}'
sleep 0.6
claude_say "已批 OK"
sleep 2.5
