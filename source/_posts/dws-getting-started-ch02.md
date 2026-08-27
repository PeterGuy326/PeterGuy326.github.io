---
title: 在 Claude / Cursor 里用一句话指挥钉钉 · dws 装进 AI Agent｜dws 专题 Ch.2
date: 2026-05-21T11:00:00+08:00
cover: /img/covers/dws-banner.png
top_img: /img/covers/dws-banner.png
description: dws 专题第二篇。装完 dws,你的 Claude / Cursor 就已经会操作钉钉了。这篇用查日程、写周报、发群通知、处理审批四个真实场景,讲清楚怎么用一句话把活交出去。
tags:
  - dws
  - DingTalk
  - CLI
  - AI Agent
  - MCP
  - 钉钉
categories:
  - dws 专题
---

上一篇 Ch.1 结尾我埋了个钩子 —— dws 装机的时候会自动往 `~/.claude/skills/dws/` 塞一份 skill 文档,所以你的 Claude、Cursor 一打开就知道怎么操作钉钉。当时说"下一篇专门写"。这篇就来还这个债。

Ch.1 你是坐在终端里一条条手敲命令。这篇换个姿势:你把要干的事用大白话讲给 Claude / Cursor,命令让它去拼、去跑。我拿自己每天真在用的四件事 —— 查日程、写周报、发群通知、处理审批 —— 一个个走一遍。

下面演示我用的是 Claude Code,Cursor、Qoder 同理,读的是同一份 skill。

---

## 先说清楚:这不是"接 API",是装了个 skill

很多人一听"让 AI 操作钉钉",第一反应是去配 MCP server、写 OpenAPI 对接。dws 这边不用。

dws 装机的时候会顺手做一件事:把一份 skill 文档同步到几个 Agent 的技能目录 ——

```
~/.claude/skills/dws/      # Claude Code
~/.cursor/skills/dws/      # Cursor
~/.agents/skills/dws/      # 其它兼容的 agent
```

这份 skill 里写了三样东西:dws 有哪 24 个产品、每类需求该走哪个产品的决策树、以及"参数拿不准时怎么用 `dws schema` 自己查"。

所以你的 Agent 不是被你"教会"操作钉钉的,是它一启动就把这份说明书读进去了。你要做的只剩一件事 —— 把需求说清楚。

底下真正干活的,还是 Ch.1 那个 dws 命令行。Agent 拼出来的,跟你手敲的是同一条命令。这点很重要:**它没有第二条暗道**,你能在终端里验证的,就是它在跑的。

---

## 30 秒确认环境

先看 skill 在不在:

```bash
ls ~/.claude/skills/dws/
```

看到 `SKILL.md` 就对了。没有的话,多半是 dws 版本太旧 —— Ch.1 说过它每周在长,升级重装一下,装机脚本会补上。

然后在 Claude Code 里直接问一句:

> 我钉钉今天有什么日程?

它要是开始跑 `dws` 命令,环境就通了。要是说"不知道怎么操作钉钉",回头检查上面那个目录。

下面正式进四个场景,按"只读 → 跨产品 → 写操作"的顺序爬坡。

---

## 场景一:查今天的日程

最简单的,从只读开始。我打字给 Claude:

> 我今天有什么安排?

Ch.1 结尾那个 Hermes 查日程的 GIF,就是这个场景。这次我们在 Claude Code 里从头走一遍,看它到底做了几步:

1. 翻 skill 的决策树,"日程 / 会议"这条路由到 `calendar`
2. 定位到 `calendar event list`,发现它要 `--start` 和 `--end` 两个 ISO-8601 时间
3. 自己算出今天的时间窗 —— 00:00 到 23:59,带上 `+08:00` 时区
4. 跑命令:

```bash
dws calendar event list \
  --start "2026-05-21T00:00:00+08:00" \
  --end   "2026-05-21T23:59:59+08:00" \
  --format json
```

5. 把返回的 JSON 整理成一句人话回我

![场景一:一句话查今日日程](/img/dws-ch02/scene1-calendar.gif)

注意第 3 步 —— "今天"这个词,是 Claude 自己翻译成具体日期的。你没给它日期,它知道今天几号、知道要补时区。这种"把模糊的话翻译成精确参数"的活,正是你用 Agent 而不是手敲的理由。

如果日程多,它还会自己在命令里加一个 `--jq` 表达式,只把时间和标题挑出来再回灌给模型 —— 这就是 Ch.1 讲过的省 token 那招。挑哪几个字段,是它查完 `dws schema` 现拼的,不是背下来的。

---

## 场景二:把这周的待办整理成周报

光查不算什么。下面这个,才是 Agent 真正比手敲省事的地方。我说:

> 把我这周做完的待办,整理成周报发出去。

这一句话,Claude 要跨两个产品(待办 `todo` + 日志 `report`)、走四步。

**① 拉本周完成的待办**

```bash
dws todo task list --status true --format json
```

这里有个细节:todo 的 `task list` 没有"按周筛"的参数,只有完成状态。所以 Claude 的做法是 —— 把已完成的待办整页拉下来,再按返回里的完成时间,自己把这周的挑出来。skill 没教它这招,是它看了参数列表自己想的。

**② 找周报模板**

钉钉日志是模板驱动的,动笔之前得先知道模板长啥样:

```bash
dws report template list --format json
```

**③ 拿模板的字段定义**

```bash
dws report template detail --name "周报" --format json
```

这步拿到的是模板里每个控件的 `key`、`sort`、`type` —— 比如"本周完成""下周计划"两栏各自的字段标识。

**④ 拼内容、提交**

```bash
dws report create --template-id <templateId> \
  --contents '[
    {"key":"本周完成","sort":"0","content":"- 修完登录页 3 个 bug\n- 上线了 dws 专题 Ch.1","contentType":"markdown","type":"1"},
    {"key":"下周计划","sort":"1","content":"- 写 dws 专题 Ch.3","contentType":"markdown","type":"1"}
  ]' \
  --format json
```

![场景二:待办自动汇成周报](/img/dws-ch02/scene2-report.gif)

整个过程我只说了一句话。Claude 把"待办"和"日志"两个本来不相干的产品,在中间用完成时间串了起来 —— 这种跨产品的胶水活,以前是你切五个网页干的,现在它一条龙跑完。

这里还有个 skill 立的规矩值得说:**写周报前必须先查模板,不许猜 `templateId` 和字段 `key`**。skill 里白纸黑字这么写,所以 Claude 不会跳过 ②③ 直接编一个模板 ID。这种"不许猜"的约束,是它能稳的关键 —— 宁可多跑两条查询,也不拿你的真实数据去赌。

---

## 场景三:在群里发个上线通知

第一个写操作。我说:

> 在「dws 专题讨论群」发个通知:今晚 10 点发布 Ch.2,大家留意。

Claude 走两步。

**① 按名字找群**

群消息要的是群的 `openConversationId`,不是群名。所以先搜:

```bash
dws chat search --query "dws 专题讨论"
```

从返回里拿到那个群的 `openConversationId`。

**② 发消息 —— 但发之前它停下来了**

这是写操作,Claude 不会闷头就发。它先把要发的内容、发到哪个群,摆出来让我确认。我回一句"确认",它才跑:

```bash
dws chat message send \
  --group <openConversationId> \
  --title "📢 发布通知" \
  --text "今晚 22:00 发布 dws 专题 Ch.2,大家留意。"
```

![场景三:一句话发群通知](/img/dws-ch02/scene3-chat.gif)

**坑还是 Ch.1 那个坑**:`--title` 必填,群聊单聊都一样。漏了的话钉钉回的是"发群服务窗会话消息失败",一个能把你带沟里的报错。dws 新版本已经在 CLI 这层前置拦截了,但你知道根因在哪不亏。

要是你想 @所有人,跟 Claude 说一句"@一下所有人"就行。它会加 `--at-all`,并且记得在正文里塞 `<@all>` 占位符 —— 这个占位符不带,@就不生效,skill 里也标了。

---

## 场景四:处理待审批

最后一个,也是最能体现"Agent 替你跑腿"的。我说:

> 看看我有什么待审批的。

**① 列出待我审的单**

```bash
dws oa approval list-pending --format json
```

Claude 把待我处理的单子列出来。我看中第一条,一个报销单,说:

> 第一个,看下内容,没问题就同意。

**② 先读单子**

```bash
dws oa approval detail --instance-id <processInstanceId>
```

它把表单字段、金额、附件拉出来,先念给我听 —— 这步是 skill 让它做的:动手之前先读懂。

**③ 换 ID —— 这步最容易被漏掉**

审批这块有个反直觉的设计:`list-pending` 给你的是**实例 ID**(`processInstanceId`),但同意 / 拒绝要的是**任务 ID**(`taskId`),两个不是一回事。中间必须再查一次:

```bash
dws oa approval tasks --instance-id <processInstanceId>
```

**④ 同意**

```bash
dws oa approval approve \
  --instance-id <processInstanceId> \
  --task-id <taskId> \
  --remark "同意,按流程推进"
```

![场景四:读单子并处理审批](/img/dws-ch02/scene4-oa.gif)

第 ③ 步那个 `processInstanceId` → `taskId` 的转换,你手敲十有八九会踩 —— 文档没翻仔细,直接拿实例 ID 去 approve,报错还看不懂。但 Claude 读过 skill,知道这里要拐个弯。**专门记这种琐碎规则,本来就是机器该干的事。**

审批是不可逆动作,所以跟场景三一样,approve 之前 Claude 一定先把"同意哪一单、什么金额"摊给你看,你点头才执行。

---

## Agent 不会偷偷删你东西

四个场景走下来,你可能注意到一个规律:**只读的它直接跑,要写、要改、要删的,它都先停一下问你。**

这不是 Claude 在客气,是 dws skill 里一条硬规定。skill 列了一张"危险操作清单" —— 删表、删记录、删字段、撤审批、撤消息……这些命令,Agent 执行前必须:

1. 把操作摘要(干啥、对谁、影响多大)摆给你看
2. 等你明确说"确认 / 好的"
3. 才允许加 `--yes` 真正执行

另外还有个 `--dry-run`,预览不执行。Agent 拿不准的时候可以先 dry-run 看一眼会发生什么,再决定要不要真干。

`--dry-run`、`--yes`、`--jq` 这三个 flag,Ch.1 末尾就列过,当时说是"让 LLM 不闯祸的最小安全网"。这一篇,你看到它们真的在四个场景里发挥作用了。

说到底,Agent 能跑多疯,边界是你给的。

---

## 这几句话背后,Agent 到底做了啥

把四个场景抽象一下,Claude 每次干的其实是同一套循环:

1. **读 skill 的决策树** —— 把你的话(日程 / 周报 / 群通知 / 审批)路由到对的产品
2. **`dws schema` 自省** —— 不确定参数名、必填项、类型时,当场查,绝不猜
3. **拼命令、跑** —— 该算时间窗算时间窗,该换 ID 换 ID
4. **`--jq` 砍输出** —— 只把有用字段回灌给模型,省 token
5. **写操作前刹一脚** —— 危险动作摆出来等你确认

你给的是**意图**,dws 给的是**确定性**。中间那段"把模糊的人话翻译成精确的命令",是这两年大模型终于做得够稳的部分。dws 做的事,就是把钉钉那 359 条能力,变成大模型够得着、又不会乱来的样子。

---

## 这个专题接下来

按 Ch.1 立的路线图,打勾的是已经写完的:

- [x] Ch.1 —— 5 分钟把钉钉装进命令行
- [x] Ch.2 —— 在 Claude / Cursor 里用一句话指挥钉钉(就是这篇)
- [ ] Ch.3 —— 群运营自动化:群消息摘要、Issue 归档、日报生成
- [ ] Ch.4 —— 安全设计:为什么敢把生产钉钉账号挂在 CLI 上
- [ ] Ch.5 —— 踩过的坑:一个开源项目的事故现场复盘

下一篇 Ch.3,把今天这些单条命令串成真正的自动化流 —— 定时跑、自动归档。评论区还是老规矩,告诉我你最想看哪一章,我按点赞排着写。

---

## 收个尾

这篇要是帮到你了,还是那两件事:

**一,去 [github.com/DingTalk-Real-AI/dingtalk-workspace-cli](https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli) 点个 Star。** Ch.1 说过,Star 数对开源维护者是实打实的信号 —— 它告诉团队"这事有人在用,值得接着做"。

**二,扫码进 dws 开源沟通群。** 钉钉打开扫一扫,群里开放平台团队 + 答疑机器人 24×7 在线,你照着这篇跑、卡在哪一步,直接群里 @ 一下。二维码是仓库 README 顶部那张官方的,归属错不了:

<p align="center">
  <img src="/img/dws-ch01/dws-group-qr-official.png" alt="dws 开源沟通群二维码" width="220">
</p>

Ch.3 见。
