---
title: Windows 下从零配置 AI 开发环境：Qoder + QoderWork + WSL + Claude Code + DeepSeek V4 Pro
date: 2026-05-05T16:00:00+08:00
cover: /img/covers/claude-code-og.png
top_img: /img/covers/claude-code-og.png
tags:
  - WSL
  - Claude Code
  - DeepSeek
  - Qoder
  - AI
categories:
  - AI 工具链
---

## 写在前面

这篇是写给 Windows 笔记本 + 纯入门 AI 状态的你的，不跳步骤、不省命令。每一段都按"先做什么、为什么这么做、出错怎么办"组织。所有链接都是官方源，AI 工具链每周都在迭代，跟着官方走最稳。

**为什么这个顺序很重要**：先装 Qoder（GUI 工具，鼠标点击即可使用），让你**先有一个能问问题的 AI 助手**。后面装 WSL、Claude Code 这些命令行工具难免遇到坑，直接把错误贴给 Qoder，它会告诉你怎么修。这就是工程师常说的"先把脚手架搭起来"。

总的安装顺序：

0. **[Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev)**（前置）：解决 GitHub / Anthropic 登不上的问题，**这是先决条件，所有后续都建立在能联网的基础上**
1. **[Qoder](https://qoder.com/)**：阿里出的 AI IDE，Windows 桌面 GUI 工具，**先装这个，后面有问题先问它**
2. **[QoderWork](https://qoder.com/qoderwork)**（**可选**）：Qoder 团队出的桌面端 AI Agent，**邀请制，提交申请后直接跳到第三步，不要卡在这里等**
3. **[WSL 2](https://learn.microsoft.com/en-us/windows/wsl/install)**：在 Windows 里装一个 Ubuntu 子系统，是后面所有 Linux 命令行工具的地基
4. **[Claude Code](https://github.com/anthropics/claude-code)**：[Anthropic](https://www.anthropic.com/) 官方的命令行 AI 编码助手
5. **接入 [DeepSeek V4 Pro](https://platform.deepseek.com/)**：把 Claude Code 的"大脑"换成 [DeepSeek](https://github.com/deepseek-ai)，省钱

预计耗时 2~2.5 小时（包含等下载和申请邀请的时间）。

---

## 第零步：网络环境准备（前置：解决登不上 GitHub / Anthropic 的问题）

> ⚠️ 这一步是后面一切的前提。如果你已经能流畅访问 https://github.com/ 和 https://docs.anthropic.com/ ，可以跳过本节直接到第一步。

### 为什么需要

后面要用到的几个核心资源在国内默认网络下可能访问不畅：
- **GitHub**（Claude Code、nvm、Clash Verge Rev 本身的下载源）
- **Anthropic 官网/文档**（Claude Code 登录与文档）
- **npm registry 的某些包**（少量包可能从 GitHub raw 拉资源）
- **Hugging Face / Docker Hub**（后面学习阶段会用到）

DeepSeek、Qoder、QoderWork 这三个国内可直连，没问题。

### 工具：[Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev)

[Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) 是目前 Windows 上最主流的开源代理客户端（GPL-3.0 协议），基于 Mihomo 内核，UI 友好，支持订阅链接一键导入。

### 离线安装（GitHub 登不上时用国内镜像）

**官方 Release 直链**（能上 GitHub 时优先用这个，最新最干净）：
- https://github.com/clash-verge-rev/clash-verge-rev/releases/latest

**国内镜像加速**（GitHub 拉不动时备用）：
在原 release 链接前加上 `https://ghproxy.com/` 或 `https://gh-proxy.com/`，例如：

```
https://gh-proxy.com/https://github.com/clash-verge-rev/clash-verge-rev/releases/latest
```

镜像服务有时会失效，遇到挂了换一个：
- ghproxy.com / gh-proxy.com / mirror.ghproxy.com / ghps.cc

下载 Windows 安装包（`Clash.Verge_x.x.x_x64-setup.exe`），双击安装即可。

### 配置：导入订阅链接 → 启用系统代理

1. 打开 Clash Verge Rev
2. 左侧"订阅"→ 粘贴你的订阅链接 → "导入"
3. "节点"页选一个延迟低的
4. 顶部"系统代理"开关打开（这一步是关键，浏览器/终端才走代理）
5. 浏览器打开 https://github.com/ 测试，能秒开就成功

### 选机场（订阅链接来源）的判断标准

订阅链接需要从付费的代理服务（俗称"机场"）购买。**这部分博客不便点名具体服务**（涉及合规、跑路风险、服务质量随时变化），但可以给你一份避坑标准：

| 维度 | 怎么看 |
|------|--------|
| **运营年限** | ≥ 2 年的相对稳定，新开 6 个月内的别碰（跑路高峰期） |
| **用户规模** | 选用户多的，节点压力分散、问题反馈快 |
| **支持协议** | 至少支持 Vless / Trojan / Hysteria2，老协议（SS、V2Ray）已过时 |
| **价格档位** | 月付 10~30 元是合理区间，太便宜（< 5 元）通常是低带宽超售 |
| **退款政策** | 有"先付后退"或试用机制的优先 |
| **官网/客服** | TG 群活跃、有正式工单系统的 > 只有客服 QQ 的 |
| **流量规则** | "不限速" 字眼大多是营销，看清月流量配额（100GB+ 够日常 AI 编码用） |

> 在身边问就读 / 工作过 1 年以上的同学/同事推荐，比看广告靠谱十倍。

### 终端代理（在 WSL Ubuntu 里也走代理）

Clash Verge 默认只代理 Windows 主机的浏览器请求，**WSL 里的 `apt`、`npm`、`git` 默认不走代理**，需要手动配置。把这段加到 `~/.bashrc` 末尾（端口默认 7897，看你的 Clash Verge"设置 → 端口"）：

```bash
# Clash Verge 代理（端口看自己 Verge 设置）
alias proxy_on='export http_proxy=http://172.17.0.1:7897 && export https_proxy=$http_proxy && export all_proxy=$http_proxy'
alias proxy_off='unset http_proxy https_proxy all_proxy'
```

> WSL 里访问 Windows 主机的 IP 不是 127.0.0.1，是 `172.17.0.1`（或在 WSL 里跑 `cat /etc/resolv.conf | grep nameserver` 看具体地址）。

要走代理时跑 `proxy_on`，不需要时跑 `proxy_off`。

📚 **官方仓库**：
- Clash Verge Rev：https://github.com/clash-verge-rev/clash-verge-rev
- Mihomo 内核：https://github.com/MetaCubeX/mihomo

---

## 第一步：安装 Qoder（AI IDE，先装这个）

### Qoder 是什么

阿里出的 AI 原生 IDE（2025 年 8 月公测），定位类似 Cursor。两个核心模式：
- **Agent Mode**：跟你结对编程，每一步都让你确认，**适合学习阶段**
- **Quest Mode**：你给它一个需求，它自己拆任务、自己写代码、自己测试

它内置 Claude / Gemini / GPT 等主流模型，自动调度，不用手动选。**关键是它有图形界面，不需要任何命令行知识就能用**——这就是为什么我建议你先装它。

### 下载安装

**这一步在 Windows 主机上做**（Qoder 是桌面 GUI 程序）。

1. 打开官网：https://qoder.com/
2. 点 "Download" 或直接：https://qoder.com/en/download
3. 选 Windows 版下载安装包，双击安装即可
4. 第一次启动时用邮箱注册 / 登录

### 第一次用怎么上手

1. 打开任意一个代码文件夹（没有的话随便建一个空文件夹）
2. 右上角有 Agent / Quest 模式切换，**先用 Agent**
3. 在对话框里直接用中文问，试试这几个：
   - "帮我写一个 hello world Python 脚本"
   - "我想学 Python，从哪开始？"
   - "解释一下什么是 API"
4. 它会主动让你确认每一次文件改动 —— 这一点对入门很友好，不会擅自修改文件

### 重要：把 Qoder 当成随时问答助手

**接下来装 WSL、Claude Code、DeepSeek 任何一步出问题，第一反应就是把错误贴给 Qoder 问怎么修**。它能联网搜索、读你的文件、给出具体的修复命令。这比直接 Google 然后翻一堆英文 Stack Overflow 高效得多。

📚 **官方资源**：
- 主站：https://qoder.com/
- 下载：https://qoder.com/en/download
- IDE 介绍：https://qoder.com/ide
- 更新日志：https://qoder.com/changelog

---

## 第二步（可选）：申请 QoderWork（桌面 AI Agent）

> 🟡 **本节为可选**。QoderWork 是邀请制，没法立刻装。**提交申请后直接跳到第三步**，不要卡在这里等。等邀请到了再回来看本节配置。如果你只想尽快上手，第二步可以完整跳过。

### QoderWork 是什么

Qoder 团队 2026 年 1 月新发布的产品，跟 Qoder 不是一回事：
- **Qoder** = AI IDE，写代码用
- **QoderWork** = 桌面端通用 AI Agent，让 AI 操作你电脑上的应用（管理文件、整理数据、写文档），跨多个 App 跑多步任务

技术上的差异：QoderWork 是 **本地优先**，任务直接在电脑上执行，不把文件反复上传服务器；遇到模糊的地方它会停下来确认，控制权始终在你这边。内置 MCP 工具支持，也能自定义 Skills。

### 重要：先认清官方网址

有个 `qoderwork.org` 是**第三方信息站**，不是官方下载源。**官方网址**：
- 产品主页：https://qoder.com/qoderwork
- 发布博客：https://qoder.com/blog/qoder-work

### 申请试用（先提交，后面慢慢等）

QoderWork 目前是 **邀请制（invite-only）**，没法立刻装。流程：

1. 打开 https://qoder.com/qoderwork
2. 点页面上的 "Request Access" 或 "Join Waitlist"
3. 用邮箱提交申请（**用刚才注册 Qoder 的同一个邮箱**，账号体系是打通的）
4. 等官方邮件邀请（一般 1~2 周）

**先提交申请放着，继续做下面的步骤。等邀请到的时候，你已经把 Qoder 用熟了，QoderWork 上手会很快。**

📚 **官方资源**：
- QoderWork 主页：https://qoder.com/qoderwork
- 发布博客：https://qoder.com/blog/qoder-work
- Qoder 全家桶更新日志：https://qoder.com/changelog

---

## 第三步：安装 WSL 2（Windows Subsystem for Linux）

> 从这一步开始进入命令行世界。**遇到看不懂的报错，截图或复制粘贴给 Qoder 问**。

### 为什么要装 WSL

Windows 自带的 PowerShell 可以用，但 AI 工具链（npm、Python、Node、各种 CLI）绝大多数都是 Linux 优先开发的。WSL 让你在 Windows 上跑一个完整的 Ubuntu，所有教程里的 `bash` 命令都能直接用，不用再做"Linux 命令翻译成 Windows 命令"这种额外功课。

### 系统要求

- Windows 10 版本 2004 及更高（Build 19041 及更高）或 Windows 11
- 在"开始菜单"输入 `winver` 可以看版本

### 安装步骤

**1. 用管理员权限打开 PowerShell**

开始菜单右键 → "终端（管理员）" 或 "Windows PowerShell（管理员）"。

**2. 一行命令安装**

```powershell
wsl --install
```

这条命令会一次性完成四件事：启用 WSL 功能、启用虚拟机平台、下载并安装 WSL 2 内核、安装默认的 Ubuntu 发行版。

**3. 重启电脑**

装完之后必须重启。重启完成后，Ubuntu 会自动启动并要求你设置：
- 一个 Linux 用户名（建议小写英文，比如英文名）
- 一个 Linux 密码（输入时屏幕不会有任何显示，这是正常的，输完直接回车）

> 这个用户名密码和 Windows 账号没关系，独立一套。记住它，后面 `sudo` 会用到。

**4. 验证安装**

回到 PowerShell 跑：

```powershell
wsl -l -v
```

正常输出应该是：

```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

VERSION 那一列必须是 **2**。如果是 1，跑：

```powershell
wsl --set-default-version 2
wsl --set-version Ubuntu 2
```

**5. 进入 Ubuntu**

以后日常使用，开始菜单搜 "Ubuntu" 直接打开即可，或者在任意终端里输 `wsl` 也能进。

### 装完先做这几件事（在 Ubuntu 里执行）

```bash
# 更新系统包索引
sudo apt update && sudo apt upgrade -y

# 装一些基础工具
sudo apt install -y curl wget git build-essential
```

📚 **WSL 官方文档**（出问题第一个查这里，第二个问 Qoder）：
- 安装指南：https://learn.microsoft.com/en-us/windows/wsl/install
- 基础命令：https://learn.microsoft.com/en-us/windows/wsl/basic-commands
- 常见问题排查：https://learn.microsoft.com/en-us/windows/wsl/troubleshooting

---

## 第四步：安装 Claude Code

### Claude Code 是什么

Anthropic 官方的命令行 AI 编码助手。在终端里跟它对话，它能读你的代码、改你的代码、跑命令、调试错误。比 ChatGPT 网页版高效得多，因为它能直接执行操作。

**Claude Code 和 Qoder 的差别**：Qoder 是图形界面（GUI），Claude Code 是命令行（CLI）。两个都装，按场景切换：看代码、Debug 用 Qoder；写脚本、跑服务器用 Claude Code。

### 前置：先装 Node.js（在 WSL Ubuntu 里）

Claude Code 通过 npm 安装，所以先要 Node.js。**不要用 `apt install nodejs`**，那个版本太旧。用 nvm（Node 版本管理器）：

```bash
# 装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# 重新加载 shell（或者关掉终端重开）
source ~/.bashrc

# 装最新 LTS 版的 Node
nvm install --lts
nvm use --lts

# 验证
node -v   # 应该是 v20.x 或更高
npm -v
```

### 安装 Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

装完验证：

```bash
claude --version
```

### 第一次启动

到任意一个项目目录（比如 `cd ~ && mkdir hello-ai && cd hello-ai`），跑：

```bash
claude
```

第一次会让你登录。如果你有 Claude 订阅或 Anthropic API Key，按提示走就行。**如果没有、想用 DeepSeek 替代，直接跳过登录、看下一节**。

📚 **Claude Code 官方文档**（域名 2026 年起从 docs.claude.com 迁移到 code.claude.com）：
- 入门概览：https://code.claude.com/docs/en/overview
- 安装与设置：https://code.claude.com/docs/en/setup
- 配置与环境变量：https://code.claude.com/docs/en/settings

---

## 第五步：把 Claude Code 接到 DeepSeek V4 Pro

### 为什么要这么做

- Anthropic 官方账号需要订阅或者付费 API，对学生不友好
- DeepSeek V4 Pro 在 SWE-Bench、LiveCodeBench 等编码基准上接近 Claude Opus 4.7，但 API 价格便宜 10 倍以上
- 关键：DeepSeek 提供了 **Anthropic 兼容的 API 端点**，只要改几个环境变量，Claude Code 就能无缝调用 DeepSeek，所有功能（hooks、skills、MCP）继续可用

### 注册 DeepSeek 账号 + 拿 API Key

1. 打开官网：https://platform.deepseek.com/
2. 注册账号（手机号或邮箱）
3. 进入 "API Keys" 页面：https://platform.deepseek.com/api_keys
4. 点 "Create new API key"，起个名字（比如 `claude-code`），复制保存好 —— **只显示一次**
5. 充值：左侧 "Top up"，5~10 元够用一阵子（DeepSeek 不是按订阅收费，按 token 实际用量计费）

### 配置环境变量（在 WSL Ubuntu 里）

把下面这段加到 `~/.bashrc` 末尾：

```bash
# === DeepSeek + Claude Code ===
export DEEPSEEK_API_KEY="sk-你刚才复制的那串key"
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="${DEEPSEEK_API_KEY}"
export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-pro"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK=1
```

编辑命令：

```bash
nano ~/.bashrc
# 滚到最底，粘贴上面那段
# Ctrl+O 保存，回车确认，Ctrl+X 退出
source ~/.bashrc
```

### 几个关键细节（一定要搞清楚）

1. **`deepseek-v4-pro[1m]` 里的 `[1m]` 不是装饰**：加上才会启用 100 万 token 的上下文窗口，不加就只有 20 万。处理大代码库时差距非常明显。
2. **Anthropic 兼容端点不是所有功能都支持**：图片、文档、网页搜索这些 content block 在 DeepSeek 端不支持，纯文本对话和工具调用没问题，日常编码够用。
3. **DeepSeek 服务器在中国**：从国内访问反而更快（200~400ms），无需额外网络配置。

### 验证接通

随便进一个目录，跑：

```bash
claude
```

进入交互后输入 `/status`，看到 base URL 是 `https://api.deepseek.com/anthropic`、model 是 `deepseek-v4-pro` 就成功了。

📚 **官方文档**：
- DeepSeek 接 Claude Code 教程：https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code
- DeepSeek Anthropic API 兼容说明：https://api-docs.deepseek.com/guides/anthropic_api
- DeepSeek 模型与定价：https://api-docs.deepseek.com/quick_start/pricing

---

## 装完之后，学习路径建议

入门 AI 不是装完工具就完事，工具只是脚手架。我给你排个 4 周的节奏：

**第 1 周：让工具用顺**
- 用 Qoder 跟读一个开源项目（去 https://github.com/ 找 star 多的小项目）
- 用 Claude Code + DeepSeek 写 5 个小脚本（文件批处理、爬虫、自动化）
- 每天跟 AI 对话至少 1 小时，先把"怎么提问"练熟

**第 2 周：搞懂底层逻辑**
- 看一遍 Anthropic 的 Prompt Engineering 文档：https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- 理解 Token、上下文窗口、Function Calling、MCP 这几个概念
- 试着给 Claude Code 写一个自定义 Skill 或 Hook

**第 3 周：动手做项目**
- 选一个真实小需求（自己的、家人的、社团的），从零做到能用
- 全程让 AI 帮你写，但每一行代码都要看懂

**第 4 周：进阶**
- 学一点 Python + LangChain / LlamaIndex，自己写个 RAG（检索增强）小应用
- 看 DeepSeek、Anthropic 的官方博客，跟住模型迭代

---

## 出问题怎么办

按这个顺序排查（这是个通用方法论）：

1. **先问 Qoder**：把错误信息整段贴进去，让它给出具体的修复命令（这就是为什么先装它）
2. **看官方文档**：链接都在每一节末尾
3. **复制错误信息去搜**：Stack Overflow、GitHub Issues 是最权威的社区资源
4. **最后再问人**：问之前先把"做了什么、出了什么错、查了什么、试了什么"列清楚

记住：**没有解决不了的环境问题，只有没花够时间的**。

---

## 一页索引（懒人速查）

| 工具 | 官网 / 官方仓库 |
|------|---------|
| Clash Verge Rev（代理客户端）| https://github.com/clash-verge-rev/clash-verge-rev |
| Qoder 官网 | https://qoder.com/ |
| Qoder 下载 | https://qoder.com/en/download |
| QoderWork 主页 | https://qoder.com/qoderwork |
| QoderWork 介绍博客 | https://qoder.com/blog/qoder-work |
| WSL 安装 | https://learn.microsoft.com/en-us/windows/wsl/install |
| nvm（Node 版本管理）| https://github.com/nvm-sh/nvm |
| Claude Code GitHub | https://github.com/anthropics/claude-code |
| Claude Code 文档 | https://code.claude.com/docs/en/overview |
| Anthropic 官网 | https://www.anthropic.com/ |
| DeepSeek GitHub | https://github.com/deepseek-ai |
| DeepSeek 平台 | https://platform.deepseek.com/ |
| DeepSeek + Claude Code 集成 | https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code |
| DeepSeek 定价 | https://api-docs.deepseek.com/quick_start/pricing |

照着做，遇到坑随时回来找我。希望下次见面时，你已经在用 Claude Code 给自己写自动化脚本了。
