---
title: 给学弟的 AI 开发环境保姆级教程：WSL + Claude Code + DeepSeek V4 Pro + Qoder + QoderWork
date: 2026-05-05T16:00:00+08:00
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

学弟你好。这篇是按你的 Windows 笔记本 + 纯入门 AI 的状态写的，不跳步骤、不省命令。每一段都按"先做什么、为什么这么做、出错怎么办"组织。所有链接都是官方源，不要去搜什么"破解版""离线包"，AI 工具链每周都在迭代，跟着官方走最稳。

总的安装顺序：

1. **WSL 2**：在 Windows 里装一个 Ubuntu 子系统，这是后面所有 Linux 命令行工具的地基
2. **Claude Code**：Anthropic 官方的命令行 AI 编码助手
3. **接入 DeepSeek V4 Pro**：把 Claude Code 的"大脑"换成 DeepSeek，省钱
4. **Qoder**：阿里出的 AI IDE，桌面 GUI 工具
5. **QoderWork**：Qoder 团队出的桌面端 AI Agent

预计耗时 1.5~2 小时（包含等下载的时间）。

---

## 第一步：安装 WSL 2（Windows Subsystem for Linux）

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

这条命令会一次性帮你做四件事：启用 WSL 功能、启用虚拟机平台、下载并安装 WSL 2 内核、安装默认的 Ubuntu 发行版。

**3. 重启电脑**

装完之后必须重启。重启完成后，Ubuntu 会自动启动并要求你设置：
- 一个 Linux 用户名（建议小写英文，比如你英文名）
- 一个 Linux 密码（输入时屏幕不会有任何显示，这是正常的，输完直接回车）

> 这个用户名密码和 Windows 账号没关系，单独一套。记住它，后面 `sudo` 会用到。

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

以后日常用的话，开始菜单搜 "Ubuntu" 直接打开就行，或者在任意终端里输 `wsl` 也能进。

### 装完先做这几件事（在 Ubuntu 里执行）

```bash
# 更新系统包索引
sudo apt update && sudo apt upgrade -y

# 装一些基础工具
sudo apt install -y curl wget git build-essential
```

📚 **WSL 官方文档**（出问题第一个查这里）：
- 安装指南：https://learn.microsoft.com/en-us/windows/wsl/install
- 基础命令：https://learn.microsoft.com/en-us/windows/wsl/basic-commands
- 常见问题排查：https://learn.microsoft.com/en-us/windows/wsl/troubleshooting

---

## 第二步：安装 Claude Code

### Claude Code 是什么

Anthropic 官方的命令行 AI 编码助手。你在终端里跟它对话，它能读你的代码、改你的代码、跑命令、调试错误。比 ChatGPT 网页版高效得多，因为它能直接"动手"。

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

第一次会让你登录。如果你有 Claude 订阅或 Anthropic API Key，按提示走就行。**如果你没有、想用 DeepSeek 替代，直接跳过登录、看下一节**。

📚 **Claude Code 官方文档**（域名 2026 年起从 docs.claude.com 迁移到 code.claude.com）：
- 入门概览：https://code.claude.com/docs/en/overview
- 安装与设置：https://code.claude.com/docs/en/setup
- 配置与环境变量：https://code.claude.com/docs/en/settings

---

## 第三步：把 Claude Code 接到 DeepSeek V4 Pro

### 为什么要这么干

- Anthropic 官方账号需要订阅或者付费 API，对学生不友好
- DeepSeek V4 Pro 在 SWE-Bench、LiveCodeBench 等编码基准上接近 Claude Opus 4.7，但 API 价格便宜 10 倍以上
- 关键：DeepSeek 提供了 **Anthropic 兼容的 API 端点**，你只要改几个环境变量，Claude Code 就能无缝调用 DeepSeek，所有功能（hooks、skills、MCP）继续可用

### 注册 DeepSeek 账号 + 拿 API Key

1. 打开官网：https://platform.deepseek.com/
2. 注册账号（手机号或邮箱）
3. 进入 "API Keys" 页面：https://platform.deepseek.com/api_keys
4. 点 "Create new API key"，起个名字（比如 `claude-code`），复制保存好 —— **只显示一次**
5. 充值：左侧 "Top up"，5~10 元够你玩一阵子（DeepSeek 不是按订阅收费，按 token 用多少花多少）

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

### 几个关键细节（学弟你一定要懂）

1. **`deepseek-v4-pro[1m]` 里的 `[1m]` 不是装饰**：加上才会启用 100 万 token 的上下文窗口，不加就只有 20 万。处理大代码库时这个差距是天和地。
2. **Anthropic 兼容端点不是所有功能都支持**：图片、文档、网页搜索这些 content block 在 DeepSeek 端不支持，纯文本对话和工具调用没问题，日常编码够用。
3. **DeepSeek 服务器在中国**：从国内访问反而更快（200~400ms），不需要科学上网。

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

## 第四步：安装 Qoder（AI IDE）

### Qoder 是什么

阿里出的 AI 原生 IDE（2025 年 8 月公测），定位类似 Cursor。两个核心模式：
- **Agent Mode**：跟你结对编程，每一步都让你确认，适合学习
- **Quest Mode**：你给它一个需求，它自己拆任务、自己写代码、自己测试，适合干活

它内置 Claude / Gemini / GPT 等主流模型，自动调度，不用你手动选。

### 下载安装

**这一步在 Windows 主机上做，不是 WSL 里**（Qoder 是桌面 GUI 程序）。

1. 打开官网：https://qoder.com/
2. 点 "Download" 或直接：https://qoder.com/en/download
3. 选 Windows 版下载安装包，双击安装即可
4. 第一次启动时用邮箱注册 / 登录

### 第一次用怎么上手

1. 打开任意一个代码文件夹
2. 右上角有 Agent / Quest 模式切换
3. 在对话框里直接用中文问："帮我读一下这个项目结构""帮我写一个 hello world"
4. 它会主动让你确认每一次文件改动 —— 这一点对入门很友好，不会偷偷搞事

### Qoder 和 Claude Code 怎么选

- **Claude Code**：纯命令行，适合服务器场景、远程开发、流水线集成
- **Qoder**：图形化 IDE，适合本地开发、看代码、Debug、新手期

两个都装，按场景切换。学习初期用 Qoder 看代码看得清楚，写脚本和服务端用 Claude Code 效率更高。

📚 **官方资源**：
- 主站：https://qoder.com/
- 下载：https://qoder.com/en/download
- IDE 介绍：https://qoder.com/ide
- 更新日志：https://qoder.com/changelog

---

## 第五步：安装 QoderWork（桌面 AI Agent）

### QoderWork 是什么

Qoder 团队 2026 年 1 月新发布的产品，跟 Qoder 不是一回事：
- **Qoder** = AI IDE，写代码用
- **QoderWork** = 桌面端通用 AI Agent，让 AI 操作你电脑上的应用（管理文件、整理数据、写文档），跨多个 App 跑多步任务

技术上的差异：QoderWork 是 **本地优先**，任务直接在你电脑上跑，不把文件反复上传服务器；遇到模糊的地方它会停下来问你确认，控制权在你这边。内置 MCP 工具支持，也能让你自定义 Skills。

### 重要：先认清官方网址

有个 `qoderwork.org` 是**第三方信息站**，不是官方下载源。**官方网址**：
- 产品主页：https://qoder.com/qoderwork
- 发布博客：https://qoder.com/blog/qoder-work

### 申请试用

QoderWork 目前是 **邀请制（invite-only）**，没法立刻装。流程：

1. 打开 https://qoder.com/qoderwork
2. 点页面上的 "Request Access" 或 "Join Waitlist"
3. 用邮箱提交申请
4. 等官方邮件邀请（一般 1~2 周）

**在等邀请的这段时间，先把 Qoder 用熟，QoderWork 上手会快很多**，因为账号体系是打通的。

📚 **官方资源**：
- QoderWork 主页：https://qoder.com/qoderwork
- 发布博客：https://qoder.com/blog/qoder-work
- Qoder 全家桶更新日志：https://qoder.com/changelog

---

## 装完之后，学习路径建议

入门 AI 不是装完工具就完事，工具是脚手架。我给你排个 4 周的节奏：

**第 1 周：让工具用顺**
- 用 Claude Code + DeepSeek 写 5 个小脚本（文件批处理、爬虫、自动化）
- 用 Qoder 跟读一个开源项目（比如 https://github.com/ 上 star 多的小项目）
- 每天跟 AI 对话至少 1 小时，先把"怎么提问"练熟

**第 2 周：搞懂底层逻辑**
- 看一遍 Anthropic 的 Prompt Engineering 文档：https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- 理解 Token、上下文窗口、Function Calling、MCP 这几个概念
- 试着给 Claude Code 写一个自定义 Skill 或 Hook

**第 3 周：动手做项目**
- 选一个真实小需求（你自己的、家人的、社团的），从零做到能用
- 全程让 AI 帮你写，但每一行代码都要看懂

**第 4 周：进阶**
- 学一点 Python + LangChain / LlamaIndex，自己写个 RAG（检索增强）小应用
- 看 DeepSeek、Anthropic 的官方博客，跟住模型迭代

---

## 出问题怎么办

按这个顺序排查（这是个通用方法论）：

1. **先看官方文档**：链接都在每一节末尾
2. **复制错误信息去搜**：Stack Overflow、GitHub Issues 是亲妈
3. **问 AI 本身**：把错误贴给 Claude Code 或 Qoder，让它帮你诊断
4. **最后再问人**：问之前先把"做了什么、出了什么错、查了什么、试了什么"列清楚

记住：**没有解决不了的环境问题，只有没花够时间的**。

---

## 一页索引（懒人速查）

| 工具 | 官方入口 |
|------|---------|
| WSL 安装 | https://learn.microsoft.com/en-us/windows/wsl/install |
| Claude Code 文档 | https://code.claude.com/docs/en/overview |
| DeepSeek 平台 | https://platform.deepseek.com/ |
| DeepSeek + Claude Code 集成 | https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code |
| DeepSeek 定价 | https://api-docs.deepseek.com/quick_start/pricing |
| Qoder 官网 | https://qoder.com/ |
| Qoder 下载 | https://qoder.com/en/download |
| QoderWork 主页 | https://qoder.com/qoderwork |
| QoderWork 介绍博客 | https://qoder.com/blog/qoder-work |

照着做，遇到坑随时找我。下次见到你的时候，希望能看到你已经在用 Claude Code 给自己写自动化脚本了。
