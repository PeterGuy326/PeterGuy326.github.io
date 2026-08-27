# 场景四: 读单子并处理审批 (instanceId → taskId 那个坑)
# 输出: source/img/dws-ch02/scene4-oa.gif

Output ../../source/img/dws-ch02/scene4-oa.gif

Set Shell "bash"
Set FontSize 16
Set Width 1280
Set Height 880
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
Type `user_say "看看我有什么待审批的。"`
Enter
Show
Sleep 1500ms

# === 步骤 1: 列待办 ===
Hide
Type `claude_think "走 oa 产品的 list-pending"`
Enter
Show
Sleep 600ms

Hide
Type `cmd_run "dws oa approval list-pending --format json --jq '.result[] | {title,processInstanceId,submitter}'"`
Enter
Show
Sleep 800ms

Hide
Type `out '[{"title":"差旅报销 1280 元","processInstanceId":"piid_001","submitter":"李四"},'`
Enter
Show
Sleep 100ms

Hide
Type `out ' {"title":"采购申请 2 台显示器","processInstanceId":"piid_002","submitter":"王五"}]'`
Enter
Show
Sleep 1500ms

# === Claude 回报 ===
Hide
Type `claude_say "2 单待你审:"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  1. 差旅报销 1280 元 (李四)"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  2. 采购申请 2 台显示器 (王五)"`
Enter
Show
Sleep 1500ms

# === 用户挑第一个 ===
Hide
Type `user_say "第一个,看下内容,没问题就同意。"`
Enter
Show
Sleep 1500ms

# === 步骤 2: 读单 ===
Hide
Type `claude_think "动手前先读详情 (skill 硬规矩)"`
Enter
Show
Sleep 500ms

Hide
Type `cmd_run "dws oa approval detail --instance-id piid_001 --format json"`
Enter
Show
Sleep 800ms

Hide
Type `out '{"title":"差旅报销","amount":1280,"reason":"上海客户拜访 2 天","attachments":["发票.pdf"]}'`
Enter
Show
Sleep 1500ms

# === 步骤 3: 换 ID (关键的坑) ===
Hide
Type `claude_think "❗ approve 要的是 taskId 不是 instanceId,必须中间再查一次"`
Enter
Show
Sleep 800ms

Hide
Type `cmd_run "dws oa approval tasks --instance-id piid_001 --format json --jq '.result[] | {taskId,userId}'"`
Enter
Show
Sleep 700ms

Hide
Type `out '[{"taskId":"tid_xyz","userId":"me"}]'`
Enter
Show
Sleep 1200ms

# === 步骤 4: 摆出来等确认 ===
Hide
Type `claude_say "准备同意,确认?"`
Enter
Show
Sleep 400ms

Hide
Type `claude_cont "  单据:    差旅报销 1280 元"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  申请人:  李四"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  事由:    上海客户拜访 2 天"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  附件:    发票.pdf"`
Enter
Show
Sleep 1500ms

# === 用户确认 ===
Hide
Type `user_say "同意"`
Enter
Show
Sleep 1000ms

# === 真批 ===
Hide
Type `cmd_run "dws oa approval approve --instance-id piid_001 --task-id tid_xyz --remark '同意,按流程推进' --format json"`
Enter
Show
Sleep 1000ms

Hide
Type `out '{"success":true}'`
Enter
Show
Sleep 600ms

Hide
Type `claude_say "已批 ✓"`
Enter
Show
Sleep 3000ms
