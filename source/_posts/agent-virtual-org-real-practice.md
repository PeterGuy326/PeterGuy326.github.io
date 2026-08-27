---
title: Agent 虚拟组织实录
date: 2026-08-10T12:20:00+08:00
description: "产品角色定范围，技术角色交付，Reviewer 打回 3 个问题；用公开 PR、CI 和一次真实 CLI 重跑复盘多 Agent 怎么接棒。"
cover: /img/covers/agent-virtual-org-enterprise.jpg
top_img: /img/covers/agent-virtual-org-enterprise.jpg
tags:
  - AI Agent
  - Multi-Agent
  - Virtual Organization
  - OpenCode
  - Digital Employee
  - Agent Infrastructure
categories:
  - 开源实践
---

PR #54 第一版 CI 是绿的，Reviewer 还是打回了 3 个具体问题。

我把问题交回技术会话，第二个 commit 修完，CI 再跑一遍，最后才合入。整个过程都能从公开的 [digital-employee #42](https://github.com/fullstack-ai-infra/digital-employee/issues/42)、[PR #54](https://github.com/fullstack-ai-infra/digital-employee/pull/54) 和 commit [`1d94ea4`](https://github.com/fullstack-ai-infra/digital-employee/commit/1d94ea4348e8fd138dde18fcf4e298f9288d02b3) 回看。

这篇只复盘已经验收的 Phase A read-only harness。Phase B/C 还在后续范围。

## 1. 我怎么摆这支小队

我在 `fullstack-ai-infra` 工作区长期留了三个角色会话：运营、产品、技术。

<img src="/img/agent-virtual-org/real-role-sessions-redacted.webp" alt="同一工作区中长期保留运营 P9、产品经理 P9、技术 P9 三个角色会话" width="420" loading="lazy" style="display:block;margin:0 auto;">

*基于真实工作区截图的脱敏处理：仅保留公开工作区名和三个角色标签；画面不含 session id、账号或路径。*

P9、P8、P7-like 是我给 Agent 用的责任标签：P9 管长期结果，P8 管一个方向，P7-like 做具体任务；人类 Owner 负责优先级、风险和最终放行。

```text
目标：P9 → P8 → task Agent
实跑：产品 P9 ↔ 技术 P9 → Gate Reviewer
                    └── 技术 P9 当时还兼任 P8 和实现
```

我说“自己的虚拟组织 CEO”，意思也很简单：问题选错、范围失控、权限放大、结果没拿到，都算我的。它不是职级，也不代表我已经搭出一支 Agent 军团。

我现在只留一条组织规则：**一个结果一个 Owner。** 跨 P9 任务再指定一个 Lead；范围或权限冲突，回到人类 Owner。

## 2. 会话怎么接棒

8 月 5 日，我遇到过一次很典型的断点：产品会话已经把 Issue 写进 GitHub，却在 readback 前失败。

我没让技术会话重试 POST，只让它回读外部状态。6 分 36 秒后，Issue 正文与冻结正文逐字节一致；接手会话的 GitHub 写入是 0，也没有多建一个 Issue。

后来我把交接压成三行：

```text
TASK     goal / revision / scope / done / dont / source
HANDOFF  verified / not_verified / next_authorized_action
GATE     READY | HOLD
```

session id 找回会话，revision 和 commit 保存事实，Handoff 告诉下一个角色还能做什么。同角色可以 resume；跨角色先回读 contract 和 commit。真实 session ref 只留本机，公开交接只用 Issue、PR、commit 和 CI。

8 月 10 日，我用 PR #54 的公开事实包重跑了一遍。Product P9 先抛出一条故意放大的主张——Phase A/B/C 都已完成；Tech P9 把 Phase B/C 标成 `NOT_VERIFIED`，Reviewer 给 HOLD；主张收窄后再过 Gate。

![Codex 多 Agent 证据门禁实跑](/img/agent-virtual-org/codex-multi-agent-gate-real-run-v1_1786355010.png)

*8 月 10 日公开事实包重跑：Handoff → HOLD → 修订 → PASS。图为真实 CLI 输出的脱敏重排版；8 月 6 日历史过程以公开 PR/CI 为准。*

这和 [OpenCode Agent](https://opencode.ai/docs/agents/) 在“角色可配置、任务可委派、child session 可恢复”这一层很像。[`task_id` 的实现](https://github.com/anomalyco/opencode/blob/0bff28de09105088ff5bdefab91413d55c28dff1/packages/opencode/src/tool/task.ts#L43-L50)也说明了它负责恢复哪一个 child session，不负责携带 revision、证据或发布授权。

我自己的分层是：OpenCode Agent 管 Host 内角色与委派；[Employee Package](https://github.com/fullstack-ai-infra/digital-employee/blob/b5531501bc86daa05a2281e93a1c9ab8a9936596/docs/employee-package.md#L97-L118) 管跨 Host 分发的岗位包；Virtual Organization 管多个岗位之间的责任、交接和 Gate。第三层还是组织协议，当前 Runtime 没有交付完整编排。

## 3. Reviewer 真打回了什么

<p align="center">
  <a href="https://github.com/fullstack-ai-infra/digital-employee/pull/54"><img src="/img/agent-virtual-org/pr54-merged-public.png" alt="公开 GitHub PR #54 已合入，包含 2 个 commit 与 5 项 checks" width="520" loading="lazy" /></a>
</p>

*公开 PR 记录：2 个 commit、5 项 checks，最终已合入。*

| 时间（2026-08-06） | 公开节点 |
| --- | --- |
| 16:55 | 产品角色发出 Phase A 交接 |
| 18:19 | 首版 commit `d4e9f56` |
| 18:43 | 技术角色创建 PR #54 |
| 19:13 | 3 项修复进入 `2c7bcc4` |
| 19:21 | 审查记录进入 PR，9 条 notes 留给 follow-up |
| 22:45 | 2 个 commit squash 合入，main 为 `1d94ea4` |

| 首版问题 | 第二个 commit |
| --- | --- |
| loopback 请求不能被 redirect 带到外部 | 禁止跟随 redirect，补 307 回归测试 |
| 非法 grant 必须返回准确错误 | 修正错误映射，补 array-shaped grant 测试 |
| component matrix 是唯一版本权威 | 移除 endpoint 与 port 硬编码 |

修复后：`npm run check` 452/452、offline 16/16、real-local 9/9 连跑两轮；两轮 CI 都是 5/5，verdict 从 `APPROVE_WITH_NOTES` 变成 `APPROVE`。[独立审查记录](https://github.com/fullstack-ai-infra/digital-employee/pull/54#issuecomment-5203993406)

[![PR #54 第二轮 CI 的 5 个 job 全部成功](/img/agent-virtual-org/pr54-ci-success-public.png)](https://github.com/fullstack-ai-infra/digital-employee/actions/runs/31096709617)

*第二个 commit 的公开 CI：5 个 job 全绿；首版 [run #51](https://github.com/fullstack-ai-infra/digital-employee/actions/runs/31094361187) 也可复核。*

首版总 verdict 是 `APPROVE_WITH_NOTES`，0 blocking；上表三项才是这次 FAIL。我选择在第二个 commit 里全部修掉，没有把“CI 绿”当成收工。

合入这里还有一个踩坑：范围角色之前写过“不走高权限路径”，后面人只回复了“批准”，授权范围没写清，技术会话随后用高权限路径完成合入。工程结果通过了，权限语义和平台 Gate 仍然有问题。

#42 的外层后来变成 closed，正文仍是 `R3 / in-progress`。所以这里接受的是 Phase A，不是整项需求。

## 4. 我现在只守三条

1. 一个结果一个 Owner。
2. 接手先回 Handoff，写清 `VERIFIED` 和 `NOT_VERIFIED`。
3. 写操作过真实 Gate，不能靠 prompt 自授权限。

session 可以换，事实留在 revision、commit 和 CI 里。

你也在跑两个以上 Agent 的话，带一次真实的 HOLD → PASS 来 [Issue #101](https://github.com/fullstack-ai-infra/digital-employee/issues/101)：目标、失败检查、修复 commit、PASS 证据。只提交你有权公开、已经脱敏的内容。
