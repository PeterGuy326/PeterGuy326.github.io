---
title: Windows 本地大模型部署完全指南：Ollama + LM Studio + 接入 Claude Code
date: 2026-05-05T17:00:00+08:00
tags:
  - 本地大模型
  - Ollama
  - LM Studio
  - Claude Code
  - AI
categories:
  - AI 工具链
---

## 写在前面

[Windows 下从零配置 AI 开发环境](/windows-ai-dev-setup-wsl-claude-code-deepseek-qoder/) 那篇主文章介绍了用云端 API（DeepSeek / Kimi）接 Claude Code，月度 ¥30 起就能跑。**还有一条路 —— 本地部署开源大模型，零 token 成本、零数据外泄、零网络依赖**，这篇专门讲。

> ⚠️ **先把丑话说在前**：本地部署不是免费午餐。**显卡门票 + 模型能力差距 + 维护负担** 三笔账都得算清楚再决定。本文第一节就是优劣对比，看完不动心再读后面。

---

## 一、本地部署 vs 云端 API：什么时候值得 DIY

### 优势 ✅

| 维度 | 说明 |
|------|------|
| **零 token 成本** | 拉一次模型，永远免费跑（除了电费）|
| **数据隐私** | 代码、文档、敏感信息全部不离开本机 |
| **离线可用** | 飞机、地铁、断网都能用 |
| **可定制** | 自己 fine-tune、自己改 prompt 模板、自己跑 RAG |
| **不限流** | 想跑多久跑多久，不会被 API 限速 |

### 弊端 ❌

| 维度 | 现实 |
|------|------|
| **硬件门槛** | 跑 7B 模型至少 8GB VRAM；想跑 32B 顶级编码模型至少 24GB（RTX 4090 起步） |
| **能力差距** | 消费级硬件能跑的 14B~32B 模型 ≈ DeepSeek V4 Flash 的水平，**远低于 V4 Pro / Claude Opus** |
| **首次下载慢** | 14B 模型量化后 ~8GB，30B ~17GB，72B ~40GB+，国内拉模型还要折腾镜像 |
| **维护负担** | 模型更新、驱动升级、量化参数调优、内存溢出排查全靠自己 |
| **响应慢** | 消费级 GPU 上 30B 模型大约 30~50 tokens/s，比云端慢 2~3 倍 |
| **上下文受限** | 实际可用上下文受 RAM 限制，不像云端动辄 1M token |

### 一句话决策

| 你的情况 | 推荐方案 |
|---------|---------|
| 笔记本 / 集显 / 8GB 以下显存 | **直接走云端 API**（[DeepSeek 主文章方案](/windows-ai-dev-setup-wsl-claude-code-deepseek-qoder/)），别折腾本地 |
| 有 RTX 3060 12GB / 4060 Ti 16GB / 4070 12GB | 可以跑 7B~14B 当**辅助**，主力还是云端 |
| 有 RTX 4090 24GB / Mac M4 Max 64GB+ | **本地 + 云端混合**，简单任务本地，复杂任务云端 |
| 数据高度敏感（代码合规 / 医疗 / 金融）| **本地优先**，云端只跑公开任务 |

> 💡 我的建议：**先按主文章方案接好云端**，等你真有"啊我这段不能让 AI 厂商看到"的需求时再来读这篇。

---

## 二、硬件门槛速查：你的机器能跑哪档模型

按 Q4_K_M 量化（默认推荐档，质量损失小、显存省 75%）的 VRAM 要求：

| 模型规模 | 量化后显存 | 代表模型 | 推荐 GPU |
|---------|----------|---------|---------|
| **3~4B** | ~2~3 GB | Qwen3 4B、Llama 3.2 3B、Gemma 3 4B | 集显 / GTX 1660 / 任意 8GB+ 内存 |
| **7~8B** | ~4~6 GB | Qwen3 8B、Llama 3.1 8B、DeepSeek-R1-Distill 7B | RTX 3060 / 4060 / Mac M2 16GB |
| **13~14B** | ~8~10 GB | Qwen3 14B、DeepSeek-R1 14B、Phi-4 14B | RTX 3060 12GB / 4060 Ti 16GB |
| **30~32B** | ~17~20 GB | Qwen2.5-Coder 32B、QwQ-32B、Qwen3 30B-A3B（MoE）| RTX 3090 / 4090 24GB / Mac M3 Max |
| **70~72B** | ~40~48 GB | Qwen3 72B、Llama 3.3 70B | RTX 6000 Ada / 双 4090 / Mac M3 Ultra 96GB+ |
| **DeepSeek V4 Pro 671B** | ~700 GB | DeepSeek V4 Pro / V3.2 全量 | **消费级跑不动**，至少 8× H100 |

> ⚠️ **关键认知**：消费级硬件（24GB 显存以内）跑得动的最大模型 ≈ **Qwen2.5-Coder 32B**（HumanEval 92.7%），相当于 DeepSeek V4 Flash 水平。**想本地跑 V4 Pro 同级模型？至少 ¥10 万级硬件投入**。

### 内存溢出的代价

显存不够、模型 spill 到 RAM 后性能**断崖式下跌**：实测 Qwen 3 8B 在 36 层只 25 层进 VRAM 时，速度从 40 tokens/s 跌到 8 tokens/s。**宁可换小一档的模型，也别让模型半装载**。

---

## 三、方案选型：Ollama vs LM Studio

| 维度 | Ollama | LM Studio |
|------|--------|-----------|
| **形态** | CLI + 后台 service | GUI 桌面 App |
| **门槛** | 命令行小白略劝退 | 鼠标点点就能用 |
| **底层引擎** | llama.cpp | llama.cpp（同款）|
| **API 兼容** | OpenAI + **Anthropic（v0.14+）** | OpenAI（端口 1234）|
| **接 Claude Code** | **原生兼容**（Ollama v0.14+），改环境变量即可 | 需要 [claude-code-router](https://github.com/musistudio/claude-code-router) 中转 |
| **MCP 支持** | 支持 | v0.3.17+ 支持 |
| **多 GPU** | 支持 | 支持高级控制（v0.3.x+）|
| **新手友好度** | 🟡 | 🟢 |
| **省心程度** | 🟢（命令行一键拉模型）| 🟡（GUI 选模型 + 调参更直观）|

> 💡 **推荐组合**：**Ollama 当主力**（CLI 适合自动化、接 Claude Code），**LM Studio 当辅助**（GUI 适合调参、对比模型、跑多模态）。两个都装，按场景切。

---

## 四、Ollama 路线（推荐）

### 4.1 安装

**方式 A：Windows 原生（推荐新手）**

打开 https://ollama.com/download/windows 下载 `OllamaSetup.exe`，双击安装。装完会自动启动后台服务。

**方式 B：在 WSL 2 里装（推荐有 WSL 环境的，性能更好）**

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

> ⚠️ 想在 WSL 里用 GPU 加速，需要 Windows 主机已装 NVIDIA Studio 驱动 + WSL 启用 CUDA。具体见 https://docs.nvidia.com/cuda/wsl-user-guide/

### 4.2 拉模型

打开终端，按你的硬件选模型：

```bash
# 8GB 显存：Qwen3 7B（轻度日常够用）
ollama pull qwen3:7b

# 12~16GB 显存：Qwen3 14B 或 DeepSeek-R1 14B（编码 + 推理推荐）
ollama pull qwen3:14b
ollama pull deepseek-r1:14b

# 24GB 显存（RTX 4090）：Qwen2.5-Coder 32B（编码王者，HumanEval 92.7%）
ollama pull qwen2.5-coder:32b

# 24GB 显存：QwQ-32B（推理王者，对标 DeepSeek-R1）
ollama pull qwq:32b

# Mac M3/M4 Max 64GB+：Qwen3 72B
ollama pull qwen3:72b
```

> 💡 Ollama 模型库完整列表：https://ollama.com/library

### 4.3 跑起来

```bash
ollama run qwen2.5-coder:32b
# 直接在终端对话；输入 /bye 退出
```

后台 API 自动监听 `http://localhost:11434`，OpenAI 兼容接口在 `/v1/chat/completions`。

### 4.4 接入 Claude Code（v0.14+ 原生 Anthropic 兼容）

Ollama 0.14 起原生支持 Anthropic Messages API，**Claude Code 直接对接，无需任何代理层**。在 WSL 的 `~/.bashrc` 末尾加：

```bash
# === Claude Code 接 Ollama 本地 ===
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_AUTH_TOKEN="ollama"
export ANTHROPIC_API_KEY=""
export ANTHROPIC_MODEL="qwen2.5-coder:32b"
export ANTHROPIC_DEFAULT_OPUS_MODEL="qwen2.5-coder:32b"
export ANTHROPIC_DEFAULT_SONNET_MODEL="qwen3:14b"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen3:7b"
```

> ⚠️ Claude Code 需要至少 64K token 上下文窗口才稳定，**确保 Ollama 模型支持长上下文**（拉模型时看 tag，比如 `qwen3:14b-instruct-q4_K_M-128k`）。

跑：

```bash
source ~/.bashrc
claude
# 进入交互后输 /status 验证 base_url 是 localhost:11434
```

> 💡 **想在多家来回切**（本地 + DeepSeek + Kimi）？用 [claude-code-router](https://github.com/musistudio/claude-code-router)，支持 `/model ollama,qwen2.5-coder` 命令热切换。

### 4.5 接入 Open WebUI（图形对话界面）

如果不想用命令行，给 Ollama 配个 ChatGPT 风格的 Web UI：

```bash
# Docker 方式（推荐）
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data --name open-webui --restart always \
  ghcr.io/open-webui/open-webui:main
```

浏览器开 `http://localhost:3000` 注册账号即可使用。

---

## 五、LM Studio 路线（GUI 党友好）

### 5.1 安装

打开 https://lmstudio.ai/ 下载 Windows `.exe`，双击安装。

### 5.2 选模型 + 下载

打开 LM Studio：

1. 左侧"🔍 Discover"标签
2. 搜 "qwen2.5-coder" 或 "deepseek-r1"
3. 选合适量化版本（一般选 **Q4_K_M**），点 Download
4. 下载完成后到"💬 Chat"标签，顶部加载模型，就能对话

### 5.3 启动本地 API server

切到"🌐 Developer"标签，启动 server（默认端口 1234）。LM Studio 提供 OpenAI 兼容接口：

```
http://localhost:1234/v1/chat/completions
```

### 5.4 接入 Claude Code（需要 claude-code-router）

LM Studio 不原生支持 Anthropic API，需要 router 中转：

```bash
npm install -g @musistudio/claude-code-router
```

编辑 `~/.claude-code-router/config.json`：

```json
{
  "Providers": [
    {
      "name": "lmstudio",
      "api_base_url": "http://localhost:1234/v1/chat/completions",
      "api_key": "lm-studio",
      "models": ["qwen2.5-coder-32b-instruct"]
    }
  ],
  "Router": {
    "default": "lmstudio,qwen2.5-coder-32b-instruct"
  }
}
```

启动 router：

```bash
ccr start
ccr code  # 启动接管后的 Claude Code
```

### 5.5 GPU 调优

LM Studio 0.3.15+ 走 CUDA 12.8，自动启用 CUDA Graph + Flash Attention。在"Settings → Server"调：

- **GPU Memory**：从 10% 到 100% VRAM 分配
- **Context Length**：7B 模型 8K 起够用，14B+ 模型上下文越长越吃显存
- **Quantization**：默认 Q4_K_M，显存余量大可以上 Q5_K_M / Q8_0

---

## 六、模型选型推荐

### 编码场景

| 显存档 | 推荐模型 | 表现 |
|-------|---------|------|
| 8 GB | `qwen2.5-coder:7b` | HumanEval 88%，日常脚手架够 |
| 12~16 GB | `qwen2.5-coder:14b` 或 `deepseek-coder-v2:lite` | 中等项目可用 |
| **24 GB** | **`qwen2.5-coder:32b`** | **本地编码王者**，HumanEval 92.7% |
| 48 GB+ | `qwen3-coder-next:80b-a3b` | 媲美云端 V4 Flash |

### 推理 / 数学场景

| 显存档 | 推荐 |
|-------|------|
| 12~16 GB | `deepseek-r1:14b`（chain-of-thought 强）|
| 24 GB | `qwq:32b`（QwQ-32B 实测对标 R1）|

### 通用对话

| 显存档 | 推荐 |
|-------|------|
| 8 GB | `qwen3:7b` 或 `gemma3:7b` |
| 12 GB+ | `qwen3:14b`（中文 + 工具调用顺滑）|

---

## 七、常见坑速查

### 坑 1：Ollama 跑模型崩溃 / 卡死

**原因**：显存爆了，模型 spill 到 RAM。

**排查**：
```bash
ollama ps   # 看模型实际占用
nvidia-smi  # 看 GPU 显存（Windows 也能在 WSL 里跑）
```

**解决**：换小一档模型，或者上更猛的量化（从 Q5_K_M 降到 Q4_K_M）。

### 坑 2：Claude Code 接 Ollama 报"context too short"

**原因**：默认 ollama 模型只有 4K~8K context。

**解决**：拉长上下文版本：
```bash
ollama pull qwen3:14b-instruct-q4_K_M-128k
```

或在 Modelfile 里手动设：
```
PARAMETER num_ctx 65536
```

### 坑 3：模型下载特别慢 / 失败

**原因**：Ollama 默认从 ollama.com 拉，国内可能不稳。

**解决**：
- 配置 [HF 镜像](https://hf-mirror.com/) 拉 GGUF 文件后用 Ollama 导入
- 或者从国内镜像（modelscope.cn）下载

### 坑 4：响应特别慢，速度 < 5 tokens/s

**排查**：
```bash
# 看是不是没用 GPU
ollama run qwen2.5-coder:32b --verbose
# 输出里看 "GPU layers: X/X"，X/X 才是全部进 GPU
```

**解决**：
- 如果 X 不等于总层数，说明显存不够，换小模型或量化
- Windows 原生 Ollama 比 WSL 快约 5~10%（少了一层 Hyper-V）

### 坑 5：本地模型工具调用（function calling）不稳定

**事实**：本地开源模型的工具调用能力**普遍不如云端**。

**解决**：
- 优先用 GLM-4.5-Air、Qwen2.5-Coder 这种明确支持 native tool calling 的
- 复杂 Agent 任务建议还是走云端 V4 Pro / Kimi K2.6

---

## 八、什么时候用本地，什么时候用云端

| 任务 | 推荐 |
|------|------|
| 改个简单 bug、写个 utility 函数 | 🏠 本地 7~14B |
| 大型重构、跨多文件改造 | ☁️ 云端 V4 Pro |
| 公司代码 / 客户数据，绝对不能外泄 | 🏠 本地 32B |
| 长文档总结 / 写文档 | ☁️ Kimi K2.6（256K 上下文）|
| 数学 / 推理任务 | 🏠 QwQ-32B 或 ☁️ DeepSeek-R1 |
| 多模态（图片/视频）| ☁️ MiniMax / Gemma 3 多模态 |
| 飞机 / 出差断网时 | 🏠 本地必选 |

> 一句话：**本地是隐私和零边际成本的安全网，云端是能力和速度的天花板**。两个都备着，按任务切，是 2026 年最舒服的姿势。

---

## 九、官方资源 & 下一步

| 工具 | 官方 |
|------|-----|
| Ollama 主站 | https://ollama.com/ |
| Ollama Windows 下载 | https://ollama.com/download/windows |
| Ollama 模型库 | https://ollama.com/library |
| Ollama Claude Code 集成 | https://docs.ollama.com/integrations/claude-code |
| LM Studio 主站 | https://lmstudio.ai/ |
| LM Studio Blog | https://lmstudio.ai/blog |
| Open WebUI | https://github.com/open-webui/open-webui |
| claude-code-router | https://github.com/musistudio/claude-code-router |
| HF 镜像（国内拉模型）| https://hf-mirror.com/ |
| ModelScope（阿里魔搭）| https://modelscope.cn/ |

回到主流程：[Windows 下从零配置 AI 开发环境](/windows-ai-dev-setup-wsl-claude-code-deepseek-qoder/)
