---
title: 5 分钟把钉钉装进命令行 · dws 入门第 1 行命令｜dws 专题 Ch.1
date: 2026-05-19T16:30:00+08:00
cover: /img/covers/dws-banner.png
top_img: /img/covers/dws-banner.png
description: dws 是钉钉开放平台团队开源的命令行工具。这篇是 dws 专题第一篇,跟着跑完,你能从零装到一条会真的发到你钉钉的命令。
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

我之前每天工作要开五个钉钉的网页。一个写文档、一个改多维表、一个看日程、一个看审批、一个发群消息。鼠标点来点去,半个上午就过去了。

后来同事推荐我装了 dws,这是钉钉开放平台团队开的一个开源命令行工具。装好之后,我现在写周报、查日程、给同事发消息基本都在终端里走，钉钉客户端能少开就少开。

这篇是我自己上手 dws 写的第一篇笔记，目的就一个 —— **5 分钟从零到一条能真的把消息发进你钉钉的命令**。我后面打算把 dws 写成一个专题系列，这是第一章。

仓库在这里，先扔上来，觉得有用顺手 Star 一下：
👉 https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli

---

## 它到底是个啥

简单说，就是把钉钉工作台搬到命令行里。日历、多维表、群消息、待办、审批、考勤、文档、云盘…… 凡是钉钉客户端能干的事，基本都给做了一条命令。

它跟普通 SDK 的区别在于：SDK 是给写代码的人用的，业务同学用不了，CI 脚本要装一堆环境，AI Agent 调用要把方法签名塞 prompt 里 token 爆炸。dws 直接做成命令行，**人能跑，shell 脚本能跑，AI Agent 也能跑** —— 这一点等会儿第四步你会看到。

它跟纯 MCP server 的区别是：MCP server 给 LLM 调可以，但人坐下来想随手查个东西，你不可能为这个先起一个 MCP 客户端。dws 底下其实也是 MCP，外面套了一层命令行壳子 + schema 自省 + 智能纠错。

ok 不废话，开跑。

---

## 装

我的环境是 macOS。Linux / Windows 也都有预编译，跨平台都行。具体安装一行命令请看仓库 README 顶部，那里是唯一的真实来源（版本会更新，我贴的容易过期）。

装完之后登录：

```bash
dws auth login
```

浏览器会弹出一个钉钉扫码授权页，你拿手机扫，授权完终端就拿到 token 了。

没浏览器的服务器环境，就 `dws auth login --device`，走设备流。

token 不是写明文文件，是落在系统的安全存储里 —— macOS 是 Keychain，Windows 是 DPAPI，Linux 是 Secret Service。这点企业 IT 看了不慌。

登好以后跑两条命令验证一下：

```bash
dws --version

dws contact user get-self --jq '.result[0].orgEmployeeModel | {name: .orgUserName, org: .orgName, dept: .depts[0].deptName}'
```

第二条会回你自己的名字、组织、部门 —— 看到自己的名字，说明终端这边已经拿到你钉钉的身份了，后面所有命令都是以你的身份在跑。

![dws --version + contact get-self](/img/dws-ch01/demo01-version-self.gif)

到这里装机就闭环了。

---

## 它到底有多大

dws 自己有个 `schema` 命令，能告诉你它当前一共有多少产品、多少条工具：

```bash
dws schema --jq '"产品 \(.products|length) 个 · 工具 \([.products[].tools|length]|add) 条"'
```

我刚才在本机跑出来是 **24 个产品 359 条工具**。

```bash
dws schema --jq '.products[] | .id' | head -12
```

这条把所有产品名列出来：aiapp、aisearch、aitable、attendance、calendar、chat、contact、devdoc、ding、doc、drive、live …… 一共 24 个。

![dws schema 自省](/img/dws-ch01/demo02-schema-scale.gif)

这里有个数字我之前印象比较深 —— 几周前 dws 还是 16 产品 204 条工具，现在已经 24 / 359 了。它每周都在长，不是个一次性的玩具项目。

附带说一下 `--jq` 这个 flag —— dws 的命令默认输出是钉钉 OpenAPI 的原始 JSON，字段又多又长。`--jq` 让你直接在命令里写 jq 表达式过滤，只把你要的字段拿出来。AI Agent 用这个 flag 能把回灌到上下文里的 token 数砍掉 90%，等会儿第四步要用到。

---

## 一行命令把消息真的发到你钉钉

这条是这篇文章最想让你跑通的：

```bash
dws chat message send \
  --user "你的钉钉 userId" \
  --title "📢 来自 dws 的第一条消息" \
  --text $'**这条消息由 dws CLI 发出**\n\n- 是真发,不是机器人\n- markdown 完整渲染\n- 来源:PeterGuy 博客'
```

跑完以后你打开钉钉，应该能在「我」自己的单聊（就是那个用自己头像的会话）里看到一条新消息，markdown 全部渲染好，加粗、列表、换行都对。

![demo03 真发钉钉](/img/dws-ch01/demo03-chat-send-real.gif)

userId 从哪儿拿？

```bash
dws contact user get-self --jq '.result[0].orgEmployeeModel.userId'
```

这条会回你自己的 userId，复制出来填到上面 `--user` 后面就行。

我写这篇的时候，自己在这条命令上踩了两个坑，写出来防身：

**坑 1：换行符**

shell 双引号里写 `"\n"` 不会展开成真换行，钉钉那边收到的是字面意义的 `\n` 两个字符。必须用 ANSI-C 单引号 `$'...\n...'`。前缀那个美元符号是关键，别漏。

**坑 2：title 必填**

不管发群还是发单聊，`--title` 都是必填的。如果你漏了，钉钉那边返回的报错是「发群服务窗会话消息失败」—— 这个错误信息有点误导，乍一看像权限问题或者群类型不对，其实就是 title 没写。我第一次卡在这儿大概折腾了十分钟。

跑成功的话返回长这样：

```json
{
  "errorCode": 0,
  "errorMessage": "ok",
  "result": { "open_taskId": "CaKpijtGnyz8/j25PIWotFaQFJ60IeK34mM1bfjP3ZQ=" },
  "success": true
}
```

`success: true` + `open_taskId`（这个是消息回执 ID，后面如果想撤回会用到）—— 看到这个就说明消息真的发出去了。

---

## 让 AI 自己跑这条命令

到这里你已经是个能用 dws 的真人了。但 dws 真正好玩的地方是 —— 它本来就是给 AI Agent 设计的。

下面这段 GIF 是 Hermes（钉钉自研的一个 Agent）调 dws 查我今日日程。我没写任何集成代码，就跟它说了一句「查一下我今天有什么日程」，剩下的它自己干完：它先跑 `dws schema` 查到 `calendar.event.list`，发现需要时间参数，自己拼了今天 00:00 到 24:00 的时间窗，调出来，再格式化成 markdown 给我。

![Hermes 调 dws 查今日日程](/img/dws-ch01/demo1.gif)

Claude Code、Cursor、Qoder 也都能跑 —— dws 装机的时候会自动同步一份 Skill 文档到 `~/.claude/skills/dws/`、`~/.cursor/skills/dws/`、`~/.agents/skills/dws/`。所以你今晚装完 dws，明早你的 Claude / Cursor 一打开就已经知道怎么操作钉钉了，不用你再教。

这个事我下一篇专门写，今天先埋个钩子。

---

## 几个 Agent 友好的 flag

dws 有三个全局 flag，如果你打算让 LLM 用它，先记一下：

`--dry-run` 是预览不执行。Agent 拿不准的时候先 dry-run 看看会发生啥，避免误删数据。

`--yes` 是跳过确认。Agent 全自动跑的时候要用，不然会卡在确认 prompt 上。

`--jq` 前面讲过了 —— 提取字段，砍 token。

这三个加起来构成的就是「让 LLM 不闯祸」的最小安全网。

---

## 安全这块简单说一句

我看了眼源码，dws 在 token 这块做得挺细：对称加密 + 密钥派生绑机器 MAC + 二次落 OS 安全存储 + 域名白名单（Bearer token 不会被偷偷发到非白名单的域名，防 SSRF）。

更重要的是，所有调用都走钉钉 OpenAPI 正向通道，管理员后台能看到每一次请求，**没有绕过审计的路径**。这点对要在公司生产环境用的人很关键。

这块我后面专门写一章，今天就提一下。

---

## 这个专题接下来会写啥

Ch.1（就是这篇）：5 分钟把钉钉装进命令行
Ch.2：在 Claude / Cursor 里用三句自然语言操作钉钉
Ch.3：群运营自动化 —— 群消息摘要、Issue 归档、日报生成
Ch.4：安全设计 —— 为什么我们敢把生产钉钉账号挂在 CLI 上
Ch.5：踩过的坑 —— 一个开源项目的事故现场全过程复盘

评论区告诉我下一篇你最想看哪一章，我按点赞排序写。

---

## 收个尾

如果今天这篇有帮到你，做两件事：

**第一件，去 [github.com/DingTalk-Real-AI/dingtalk-workspace-cli](https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli) 点个 Star。**

开源项目 Star 数对维护者的意义很实在 —— 不是虚荣，是它告诉团队「这事有人用，值得继续做」。dws 团队在群里 24 小时挂着答疑机器人，社区已经 1200+ 工程师了，每周 80+ 条工具往上加。再加点燃料，这个项目能跑得更远。

**第二件，扫码进 dws 开源沟通群。**

钉钉打开扫一扫，群里 dws 开放平台团队 + D仔答疑机器人 24×7 在线，遇到坑随时 @ 一下，团队天天在答疑。这张二维码就是 dws 仓库 README 顶部那张，官方挂着的，归属错不了。

<p align="center">
  <img src="/img/dws-ch01/dws-group-qr-official.png" alt="dws 开源沟通群二维码" width="220">
</p>

下一章见。

