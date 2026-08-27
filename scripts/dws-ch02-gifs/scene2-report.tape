# 场景二: 待办自动汇成周报 (跨产品 todo + report)
# 输出: source/img/dws-ch02/scene2-report.gif

Output ../../source/img/dws-ch02/scene2-report.gif

Set Shell "bash"
Set FontSize 16
Set Width 1280
Set Height 820
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
Type `user_say "把我这周做完的待办,整理成周报发出去。"`
Enter
Show
Sleep 1500ms

# === Claude reasoning: 这要跨两个产品 ===
Hide
Type `claude_think "拆解: 待办(todo) + 日志(report) 跨产品"`
Enter
Show
Sleep 700ms

# === 步骤 1: 拉本周完成的待办 ===
Hide
Type `claude_think "① 先拉已完成待办,按完成时间挑本周"`
Enter
Show
Sleep 500ms

Hide
Type `cmd_run "dws todo task list --status true --format json --jq '.result.tasks[] | select(.finishTime > 1747958400000)'"`
Enter
Show
Sleep 800ms

Hide
Type `out '[{"subject":"修完登录页 3 个 bug","finishTime":1748044800000},{"subject":"上线 dws 专题 Ch.1","finishTime":1748131200000}]'`
Enter
Show
Sleep 1500ms

# === 步骤 2: 找模板 ===
Hide
Type `claude_think "② 钉钉日志模板驱动,先查有哪些模板"`
Enter
Show
Sleep 500ms

Hide
Type `cmd_run "dws report template list --format json --jq '.result.templates[] | {name,templateId}'"`
Enter
Show
Sleep 700ms

Hide
Type `out '[{"name":"周报","templateId":"tpl_zhoubao_001"},{"name":"日报","templateId":"tpl_ribao_002"}]'`
Enter
Show
Sleep 1200ms

# === 步骤 3: 拿模板字段 ===
Hide
Type `claude_think "③ 拉周报模板的字段定义 (key/sort/type)"`
Enter
Show
Sleep 500ms

Hide
Type `cmd_run "dws report template detail --name '周报' --format json"`
Enter
Show
Sleep 800ms

Hide
Type `out '{"fields":[{"key":"本周完成","sort":"0","type":"1"},{"key":"下周计划","sort":"1","type":"1"}]}'`
Enter
Show
Sleep 1200ms

# === 步骤 4: 摆内容等确认 ===
Hide
Type `claude_say "周报内容拟好了,确认发吗?"`
Enter
Show
Sleep 600ms

Hide
Type `claude_cont "  [本周完成]"`
Enter
Show
Sleep 200ms

Hide
Type `claude_cont "    - 修完登录页 3 个 bug"`
Enter
Show
Sleep 200ms

Hide
Type `claude_cont "    - 上线 dws 专题 Ch.1"`
Enter
Show
Sleep 300ms

Hide
Type `claude_cont "  [下周计划]"`
Enter
Show
Sleep 200ms

Hide
Type `claude_cont "    - 写 dws 专题 Ch.3"`
Enter
Show
Sleep 1500ms

# === 用户确认 ===
Hide
Type `user_say "发"`
Enter
Show
Sleep 1000ms

# === 真正提交 ===
Hide
Type `cmd_run "dws report create --template-id tpl_zhoubao_001 --contents '[...]' --format json"`
Enter
Show
Sleep 800ms

Hide
Type `out '{"success":true,"reportId":"rpt_20260523_001"}'`
Enter
Show
Sleep 800ms

Hide
Type `claude_say "已提交 ✓  报告 ID: rpt_20260523_001"`
Enter
Show
Sleep 3000ms
