---
title: Git Release SOP — 通用 AI Agent 发版副驾手册
date: 2026-05-09T00:23:41+08:00
updated: 2026-05-10T00:50:00+08:00
cover: /img/covers/git-skill-og.png
top_img: /img/covers/git-skill-og.png
tags:
  - DevOps
  - Release
  - Git
  - AI Agent
  - Claude Code
  - Qoder
  - Cursor
  - SOP
categories:
  - 工程实践
---

> 本文给出一套**与项目语言/工具链/Agent 无关**的 Git 项目发布 SOP，覆盖准入 → 预演 → 打 Tag → 自动化 → 验证 → 闭环七步走，附故障预案、回滚策略、Hotfix 流程，以及一份可装入**任意 AI Agent**（Claude Code / Qoder / Cursor / 通用 LLM 都行）的 **release-sop skill**——来自 [`PeterGuy326/git-skill`](https://github.com/PeterGuy326/git-skill) 这个 Git 工作流通用 AI Agent skill 集合。
>
> 文末附上以 [DingTalk Workspace CLI](https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli)（Go + GoReleaser）作为具体案例的实战映射。
>
> **Git 而非 GitHub**：SOP 主体（PR 准入、CHANGELOG、tag 触发、smoke）对 GitHub / GitLab / Gitea / 自建 Gitea 都适用。**Agent 不锁死**：skill 的载体是一份纯 markdown 行为契约，能装进 Claude Code 的 SKILL.md，也能贴进 Qoder 的 system prompt、Cursor 的 `.cursorrules`、ChatGPT 的 Custom GPT 指令——每个 agent 一个安装路径，行为对齐。

<!-- more -->

## 0. 为什么需要发布 SOP

发布的本质不是"把代码推出去"，是"把承诺交付给用户"。承诺要可重复、可追溯、可回滚——这就是 SOP 存在的意义。

很多团队的发版翻车，不是工具的问题，是**链路里没有单一信任源**：有人在本地 `npm publish`，有人在 CI 打 tag，有人手工 `gh release create`，最后回滚时找不到入口。

本 SOP 钉死一件事：

> **Tag 是发布的唯一触发器，CI 是唯一执行者，CHANGELOG 是唯一信任源。**

---

## 1. 顶层设计

```
┌──────────────────────────────────────────────────────────────────────────┐
│  单一发布主链路（Single Release Pipeline）                                 │
├──────────────────────────────────────────────────────────────────────────┤
│  PR 准入 ─►  本地 Pre-flight ─►  CHANGELOG 终稿 ─►  打 Tag                │
│                                                       │                    │
│                                                       ▼                    │
│  发布后验证 ◄─  盯盘 release.yml ◄─  自动构建 / 发包 / 通知              │
│        │                                                                   │
│        └►  DOD 闭环：smoke / 多渠道一致性 / 团队播报 / 卡片关闭           │
└──────────────────────────────────────────────────────────────────────────┘
```

5 个阶段、3 条红线、1 个闭环报告。

---

## 2. 角色与 Owner

| 角色 | 责任 | 禁区 |
|---|---|---|
| **Release Captain** | 起 tag、盯 CI、出问题第一响应 | 不准跳过 CI 闸 |
| **PR Owner** | 自己代码自己保 CHANGELOG/测试/文档 | 不准让 Captain 替你写 |
| **Reviewer** | review 时检查接口/产物/兼容性 | 不准 LGTM 后才发现要改 |
| **Maintainer 排班** | 凭据轮换（npm/Homebrew/Docker token） | 凭据不进仓库、不进 PR |

> **每个 release 必须有一个具名 Captain。** Captain 在发布闭环前不切换、不并发。

---

## 3. 版本号规则（SemVer）

| 变化类型 | 版本位 |
|---|---|
| 不兼容的 API / CLI / 退出码 / 数据格式变化 | **MAJOR** |
| 新功能、新命令、新参数（向后兼容） | **MINOR** |
| Bug fix、性能、文档、内部重构 | **PATCH** |

**Breaking change 必须**：
1. CHANGELOG 顶端单列 `### Breaking` 段落
2. PR 标题前缀 `breaking:` 或 body 中显式标注
3. 至少一个 minor 周期内的 deprecation 提示（豁免：安全/合规）

---

## 4. PR 准入（Definition of Ready for Merge）

**Release 阶段不做新检查，只做"重放 PR 阶段已经过的检查"。**

通用准入清单：

- [ ] CI 全绿（lint + unit test + integration test + race detector）
- [ ] 行为/接口变化 → CHANGELOG 已更新（Keep a Changelog 格式 + PR 号 + Issue 号）
- [ ] 单测/回归测试与实现同 PR 提交
- [ ] PR 描述带 verification evidence（命令 + 输出截图）
- [ ] 涉及打包/installer → 本地 dry-run 通过
- [ ] 安全敏感变更 → 走 SECURITY.md / 内部安全 review

CI 至少应有 5 道闸（按需扩展）：**lint / test / coverage / policy / 端到端契约**。

---

## 5. Release 五阶段流程

### 阶段 1 — Pre-flight（T-30min）

Captain 在主分支 HEAD 上完成：

```bash
# 通用骨架（按项目工具链替换）
git checkout main && git pull --ff-only
<lint command>            # eg. make lint, npm run lint, cargo clippy
<test command>            # eg. make test, npm test, cargo test
<package dry-run>         # eg. goreleaser release --snapshot --clean
                          #     npm pack --dry-run
                          #     cargo publish --dry-run
                          #     poetry build --dry-run
<artifact verify>         # 检查 dist/ 产物完整、checksums、版本号正确
```

**通过标准**：所有命令绿、产物清单与历史版本一致、版本号已 bump。

> **失败处置**：任何一项红 → **不打 tag**，回到 PR 流程修复。绝不带病发布。

### 阶段 2 — CHANGELOG 终稿（T-15min）

按 [Keep a Changelog](https://keepachangelog.com/) 格式在 `CHANGELOG.md` 顶端起新段落：

```markdown
## [X.Y.Z] - YYYY-MM-DD

<一句话总览本次发布的核心价值>

### Breaking | Added | Changed | Fixed | Deprecated | Removed | Security
- **<用户可观测的现象>** (#PR, fixes #ISSUE) — <根因 + 修复方式 + 影响面>
```

**风格约束**：
- 每条以"用户可观测现象"开头加粗
- 必带 PR 号；修 issue 必带 `fixes #N`
- 禁止"修了一个 bug"这类无颗粒度描述
- CHANGELOG 走普通 PR 合入 main，**不夹带在 tag commit 里**

### 阶段 3 — 打 Tag 触发发布（T-0）

```bash
git checkout main && git pull --ff-only
git log -1 --oneline                     # 确认 HEAD 是 CHANGELOG 落地的 commit
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

> **Tag 是唯一触发器**。push 后 `.github/workflows/release.yml` 立即开跑。

### 阶段 4 — 盯盘 release.yml（T+0 ~ T+10min）

逐步确认每个 step 通过。常见 step 模板：

| Step | 通过标志 |
|---|---|
| Checkout / Setup runtime | 拉取 `go.mod` / `package.json` / `pyproject.toml` 指定版本 |
| Build & Package | 产出多平台 archive、checksums |
| Upload to GitHub Release | Release 页所有 asset 齐全 |
| Publish to package registry | npm / PyPI / crates.io / Docker registry 出现新版本 |
| Notify downstream | webhook / 通知群消息发出 |

**release.yml 跑完 ≠ 发布闭环**。继续阶段 5。

### 阶段 5 — 发布后验证（T+10 ~ T+30min）

**所有验证由 Captain 亲自跑，不能假设"CI 过了就行"**：

```bash
# 5.1 直接二进制/包下载校验
curl -fL -o /tmp/artifact <release URL>
sha256sum /tmp/artifact   # 与 checksums.txt 对照

# 5.2 干净环境 smoke test
HOME=$(mktemp -d) <package manager install command> <pkg>@X.Y.Z
HOME=$(mktemp -d) <bin> --version | grep "vX.Y.Z"
HOME=$(mktemp -d) <bin> --help >/dev/null

# 5.3 关键路径功能验证
<至少 1 个用户最常用的功能跑一遍>
```

**全部 OK 后**：
- 团队群播报：版本号 / 关键变更 1-3 条 / Release 链接
- 关闭本次 release 关联的 milestone / 项目卡

---

## 6. 命令速查表

```bash
# 本地干跑（按工具替换）
goreleaser release --snapshot --clean      # Go
npm pack && npm publish --dry-run          # Node
cargo publish --dry-run                    # Rust
poetry build && twine check dist/*         # Python

# 正式发布（推 tag 即可，CI 自动）
git tag -a vX.Y.Z -m "Release vX.Y.Z" && git push origin vX.Y.Z

# 灾备：CI 不可用时本地发布
<手工构建> && <手工 publish>               # 仅紧急时使用，事后必须修复 CI

# 回滚 / 撤销
gh release delete vX.Y.Z --yes
git push --delete origin vX.Y.Z            # 慎用，见 §8
npm deprecate <pkg>@X.Y.Z "yanked: <reason>"
yank crate / withdraw PyPI release ...
```

---

## 7. 故障预案（Runbook）

| 阶段 | 症状 | 处置 |
|---|---|---|
| 构建失败 | dist 不全、Action 红 | 看日志末尾 50 行定位阶段；锁工具版本；**绝不**手工上传残缺包 |
| 发包失败 401/403 | 凭据过期 | 维护者轮换 token，重跑 workflow |
| 发包版本冲突 | 同号已存在 | **禁止 unpublish 重发**，必须 bump 到下一 patch |
| 下游通知失败 | webhook 静默 | 检查 secret 是否配置；按需手工 `curl --fail` 重放 |
| Release 资产缺漏 | gh release view 少文件 | 手工 `gh release upload --clobber` 补传 |

---

## 8. 回滚与 Yank 策略

**优先级：bump 新版本 > yank 旧版本 > 删 tag**。

| 严重度 | 处置 |
|---|---|
| 编译/启动失败、命令完全不可用 | 立即发 patch 修复版；旧版本 GitHub Release 加 `⚠️ Yanked` 前缀；包仓库 deprecate |
| 数据/账号安全问题 | 同上 + 团队群红字播报 + 触发 SECURITY.md 流程 |
| 文档错误、措辞不当 | 不回滚，下个 patch 一起改 |

**删 tag**：仅限 tag push 30 分钟内、且 release.yml 还没成功完成的情况。否则会留下断裂的下游引用。

---

## 9. Hotfix 流程

适用：线上版本出现 P0/P1 问题，无法等待下个常规 release。

1. 从最近的稳定 tag 切 `hotfix/X.Y.(Z+1)` 分支
2. 只 cherry-pick 修复 commit，不带其他 PR
3. 走完阶段 1 ~ 阶段 5 全流程（**不能因为"急"跳闸**）
4. Hotfix 合并后必须 forward-merge 回 `main`，避免 main 落后

> 加急 ≠ 减步骤。减的是排队时间，不是验证步骤。

---

## 10. DOD（Definition of Done）

每次 release 完成后，Captain 在 release issue / 卡片上勾完以下，才算闭环：

- [ ] tag `vX.Y.Z` 在 main HEAD 上
- [ ] GitHub Release 页含全部预期 asset + checksums
- [ ] 所有目标包仓库可拉取（npm / PyPI / crates.io / Docker / Homebrew）
- [ ] CHANGELOG.md 与 release 一致（无 backfill TODO）
- [ ] smoke test 在至少 2 个目标平台跑过
- [ ] 团队 / 下游已周知
- [ ] 关联 milestone / 卡片关闭

**任何一项未勾 = 此次发布未闭环。**

---

## 11. 三条红线

1. **不在 CI 红的状态下打 tag**
2. **不 unpublish / unyank 已发布的版本号**（永远 bump 下一位）
3. **不让 Captain 同时跑两个 release**

---

## 12. 案例：DingTalk Workspace CLI（Go + GoReleaser）

把上面的通用 SOP 落到一个真实项目上是什么样：

| 通用步骤 | dws 具体命令 |
|---|---|
| Pre-flight lint+test | `./scripts/dev/ci-local.sh && make policy` |
| Pre-flight 打包 dry-run | `make package && ./scripts/release/verify-package-managers.sh` |
| Pre-flight goreleaser 干跑 | `goreleaser release --snapshot --clean` |
| 打 tag | `git tag -a vX.Y.Z -m "Release vX.Y.Z" && git push origin vX.Y.Z` |
| CI workflow | `.github/workflows/release.yml`（GoReleaser + post-goreleaser.sh + npm publish） |
| 产出物 | 7 个 archive（darwin/linux/windows × amd64/arm64）+ checksums + dws-skills.zip + npm 包 |
| 多渠道 | GitHub Releases / npm `dingtalk-workspace-cli` / Homebrew tap |
| smoke | `HOME=$(mktemp -d) npm i -g dingtalk-workspace-cli@X.Y.Z && dws --version` |

仓库：<https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli>，发布频率约 1-2 天一版（一个月发了 23 个版本），SOP 在高频迭代下经过实战检验。

---

## 13. 把 SOP 装进 AI Agent — release-sop Skill

把上面这套流程**编码成一份 AI Agent skill**，下次发版让你的 agent 副驾按 SOP 强制走完闭环。**Skill 的本体是一份纯 markdown 行为契约**——Claude Code 能读、Qoder 能读、Cursor 能读、ChatGPT Custom GPT 也能读，每个 agent 只是安装路径不同。

### 项目仓库：`git-skill`

skill 不孤立——release-sop 是 [`PeterGuy326/git-skill`](https://github.com/PeterGuy326/git-skill) 这个 **Git 工作流通用 AI Agent skill 集合**里的第一个 skill。仓库定位是承载一族围绕 Git 主机（GitHub / GitLab / Gitea）的工程流程 skills，每一个都是一份带硬闸的可重复流程：

| Skill | 状态 | 干什么 |
|---|---|---|
| `release-sop` | ✅ 已发布 | 本文主角，7 阶段发布 SOP |
| `pr-review` | 🚧 规划中 | 按清单走结构化 PR review（接口变更、测试覆盖、CHANGELOG、安全 review 触发条件） |
| `issue-triage` | 🚧 规划中 | 进来的 issue 按严重度 / 区域 / 是否可执行做分类，给一行书面理由 |
| `changelog-bot` | 🚧 规划中 | 走 PR diff 自动生成 Keep a Changelog 风格的词条建议 |
| `hotfix-flow` | 🚧 规划中 | 只 cherry-pick 的 hotfix 分支流程，最后强制 forward-merge 回 main |

底层逻辑：**单 skill 仓库容易腐烂**——5 个 skill 5 个仓维护成本爆炸，但其中只有 1-2 个会被持续打磨。归到一个仓里，复用 README、CHANGELOG、install 脚本、issue tracker，发版节奏拉通。仓库整体走 SemVer，单个 skill 行为变更体现在 CHANGELOG 词条里。

### 多 Agent 安装路径

仓库 `skills/<skill-name>/SKILL.md` 是**单文件**——这份文件的内容（含 frontmatter）就是 skill 的全部，把它喂给任何 agent 即可：

| Agent | 安装路径 | 触发方式 | 注意事项 |
|---|---|---|---|
| **Claude Code** | `~/.claude/skills/release-sop/SKILL.md`（用户级）<br>或 `<project>/.claude/skills/release-sop/SKILL.md`（项目级） | `/release-sop`、`帮我发版 vX.Y.Z` 等自然语言触发 | frontmatter `name: release-sop` 自动加载，重启会话生效 |
| **Qoder** | 在 Qoder 工作流 / Custom Mode 的 system prompt 里粘贴 SKILL.md 全文（去掉 frontmatter） | 在该 mode 下直接说 "帮我发版 vX.Y.Z"、"cut release" | Qoder 没有 frontmatter 概念，删掉 `---...---` 块即可 |
| **Cursor** | `<project>/.cursorrules` 末尾追加 SKILL.md 正文（或单独建 `.cursor/rules/release-sop.mdc`） | 让 Cursor Composer/Agent 模式触发"按 release-sop 走" | `.mdc` 格式可保留 frontmatter，传统 `.cursorrules` 去掉 |
| **ChatGPT Custom GPT** | "Instructions" 输入框粘贴 SKILL.md 全文 | 用一个独立 GPT 专跑这个 skill | 触发词写进 GPT 的 description |
| **通用 LLM**（Gemini/DeepSeek/Kimi/通义） | 每次会话开头粘贴 SKILL.md 作为 system / first user message | 直接 "现在按上面的 SOP 走，帮我发版 vX.Y.Z" | 长 SOP 占 token，建议截取主流程或挂为外部 reference |

> **跨 agent 不变量**：行为契约（Step 0-8、硬闸、5 条红线、回滚策略）一份原文。**变量**：触发协议、frontmatter 形态、加载机制——这是各 agent 自己的事，skill 内容不为某一家定制。

### 一行命令安装（Claude Code 用户）

```bash
mkdir -p ~/.claude/skills/release-sop && \
  curl -fsSL https://raw.githubusercontent.com/PeterGuy326/git-skill/main/skills/release-sop/SKILL.md \
  -o ~/.claude/skills/release-sop/SKILL.md
```

### 多 skill 批装（`install.sh`，目前优先 Claude Code 路径）

```bash
git clone https://github.com/PeterGuy326/git-skill ~/.claude/git-skill-src
cd ~/.claude/git-skill-src
./install.sh release-sop                # 装一个，用户级 ~/.claude/skills/<name>/
./install.sh release-sop --project      # 装一个，项目级 ./.claude/skills/<name>/
./install.sh --all                      # 装本仓全部 skill
./install.sh --list                     # 看可装清单
```

> Qoder / Cursor / 通用 LLM 用户暂时手工粘贴；后续 `install.sh` 会加 `--target qoder|cursor` 之类的渠道分发，欢迎在仓库 issue 里提诉求。

### 触发词（Claude Code）

- 显式：`/release-sop`
- 隐式：`帮我发版`、`走 release SOP`、`release sop`、`发 X.Y.Z`、`cut a release`、`tag and release`

其他 agent 根据各自的触发协议自然语言走，行为契约一致。

### Skill 源码

> 下面这段是 `skills/release-sop/SKILL.md` 的完整内容，仓库里也直接同源（路径见上）。**Claude Code 用户**：连 frontmatter 一起复制保存。**其他 agent 用户**：去掉 `---...---` frontmatter 块，把剩下的正文喂给你的 agent 即可。


````markdown
---
name: release-sop
description: 通用 Git 项目发布 SOP 引导 skill（适用于 GitHub / GitLab / Gitea 等 Git 主机；可装入 Claude Code / Qoder / Cursor / 通用 LLM 等任意 AI Agent）。按"PR准入回放 → Pre-flight → CHANGELOG → 打Tag → 盯盘 → 发布后验证 → DOD"七步走，每步有 gate、命令、失败处置；自动识别项目类型（Go/Node/Python/Rust/Docker）适配命令。Triggers on '/release-sop', 'release sop', '发版sop', '走发版流程', '帮我发版', 'cut a release', 'tag and release'.
---

# Release SOP — 通用 Git 项目发布流程（多 Agent 兼容）

## 触发条件

用户提到以下任一即激活：
- 显式：`/release-sop`、`release sop`、`发版 sop`、`走发版流程`
- 隐式：`帮我发版`、`发 vX.Y.Z`、`cut a release`、`tag and release`、`打 tag 发布`

## 行为协议

你是 Release Captain 的副驾。你不是按钮工——你是承诺的 co-owner。

激活后立即按以下步骤执行，**任何 gate 失败立即停在该步，不允许跳过**。

---

### Step 0 — 项目识别

读取仓库根目录，识别项目类型与发布工具：

| 探针 | 推断 |
|---|---|
| `.goreleaser.yaml` / `.goreleaser.yml` | Go + GoReleaser |
| `package.json` 含 `"publishConfig"` 或 npm scripts | Node + npm |
| `pyproject.toml` / `setup.py` | Python + poetry/twine |
| `Cargo.toml` 含 `[package]` | Rust + cargo |
| `Dockerfile` + GHCR/Docker Hub 配置 | Docker image |
| `.github/workflows/release*.yml` | 已有 release 自动化 |

输出探测结论：项目类型、发布工具、CI workflow 路径、发布渠道清单。

### Step 1 — 身份对齐（必跑，不能跳）

向用户问清以下，缺一不补齐就**禁止进入 Step 2**：

1. **目标版本号** `vX.Y.Z`（必须 SemVer，含 `v` 前缀）
2. **Release Captain**（必须是单一具名 owner，不接受"我们"）
3. **本次发版核心价值**（一句话，将写入 CHANGELOG 段落首句）
4. **是否含 Breaking change**（含则要求列出 breaking 项）

### Step 2 — PR 准入回放（DoR Check）

读取仓库 `CONTRIBUTING.md` 与 `.github/workflows/*.yml`，逐条回放 PR 阶段应过的闸：

- [ ] CI 全绿（lint / unit test / integration test / race / coverage / policy）
- [ ] 行为/接口变化对应 PR 已写好 CHANGELOG 词条
- [ ] 单测/回归测试与实现同 PR 提交
- [ ] 涉及打包/installer 已 dry-run

任意一项 NO → 停在 Step 2，要求用户回 PR 流程修复。

### Step 3 — Pre-flight

按 Step 0 探测的项目类型，引导用户执行对应命令并粘贴输出。命令模板：

```bash
git checkout main && git pull --ff-only
<lint command>
<test command>
<package dry-run command>
<artifact integrity check>
```

具体命令参考：

- **Go + GoReleaser**: `goreleaser release --snapshot --clean`
- **Node + npm**: `npm ci && npm test && npm pack --dry-run`
- **Python + poetry**: `poetry install && poetry run pytest && poetry build`
- **Rust + cargo**: `cargo test && cargo publish --dry-run`
- **Docker**: `docker build -t <img>:test . && docker run --rm <img>:test --version`

验收：所有命令绿、产物清单完整、版本号正确。

### Step 4 — CHANGELOG 终稿

引导用户在 `CHANGELOG.md` 顶端按 Keep a Changelog 格式起新段落：

```markdown
## [X.Y.Z] - YYYY-MM-DD

<一句话总览>

### Breaking | Added | Changed | Fixed | Deprecated | Removed | Security
- **<用户可观测现象>** (#PR, fixes #ISSUE) — <根因 + 修复方式 + 影响面>
```

约束：
- 每条以"现象"开头加粗
- 必带 PR 号；修 issue 必带 `fixes #N`
- 禁止"修了一个 bug"这类无颗粒度描述
- CHANGELOG 走普通 PR 合入 main，不夹带在 tag commit 里

### Step 5 — 打 Tag 触发发布

```bash
git checkout main && git pull --ff-only
git log -1 --oneline    # 确认 HEAD 是 CHANGELOG 落地的 commit
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

push 后立即把 GitHub Actions URL 给用户，进入"盯盘"。

### Step 6 — 盯盘 release.yml

逐步确认每个 step 的通过标志（参考 Step 0 的 workflow 路径）：

| 通用 Step | 通过标志 |
|---|---|
| Checkout / Setup runtime | 版本与代码声明一致 |
| Build & Package | dist/ 产物完整 |
| Upload to GitHub Release | Release 页 asset 齐全 |
| Publish to registry | 包仓库出现新版本 |
| Notify downstream | webhook 已发出 |

每一步出问题 → 进 §故障预案，不允许跳到 Step 7。

### Step 7 — 发布后验证

要求 Captain 亲自跑（不能假设"CI 过了就行"）：

```bash
# 二进制/包下载校验
curl -fL -o /tmp/artifact <release URL>
sha256sum /tmp/artifact

# 干净环境 smoke
HOME=$(mktemp -d) <install command>
HOME=$(mktemp -d) <bin> --version | grep "vX.Y.Z"
HOME=$(mktemp -d) <bin> --help >/dev/null

# 关键路径功能验证
<至少 1 个用户最常用功能>
```

### Step 8 — DOD 闭环

逐项勾选才允许"发布完成"：

- [ ] tag `vX.Y.Z` 在 main HEAD
- [ ] GitHub Release 含全部预期 asset + checksums
- [ ] 所有目标包仓库可拉取
- [ ] CHANGELOG 与 release 内容一致
- [ ] smoke test 在 ≥2 平台通过
- [ ] 团队/下游已周知
- [ ] milestone / 卡片关闭

输出闭环报告（markdown 表格）：版本号、Captain、tag SHA、Release URL、各包仓库 URL、smoke 结果、耗时。

## 故障预案

| 阶段 | 现象 | 处置 |
|---|---|---|
| 构建失败 | dist 不全 | 看 Actions 日志末尾 50 行；锁工具版本；**绝不**手工上传残缺包 |
| 发包 401/403 | 凭据过期 | 维护者轮换，重跑 workflow |
| 发包版本冲突 | 同号已存在 | **禁止 unpublish 重发**，必须 bump patch |
| Release 资产缺漏 | gh release view 少文件 | 手工 `gh release upload --clobber` 补传 |
| 下游通知失败 | webhook 静默 | 检查 secret；按需手工 `curl --fail` 重放 |

## 回滚

优先级：**bump 新版本 > yank 旧版本 > 删 tag**。

- 严重 P0：发 patch + Release 标 `⚠️ Yanked` + 包仓库 deprecate
- 安全/合规：同上 + 红字播报 + 走 SECURITY.md 流程
- 删 tag 仅限 push 30 分钟内 且 release.yml 未成功

## 红线（不可越）

1. **不在 CI 红的状态下打 tag**
2. **不 unpublish 同号包**
3. **不跳过 PR 准入回放**
4. **不让 Captain 同时跑两个 release**
5. **不夹带其他 commit 进 hotfix**

## 输出风格

- 每个 step 开始前：明确告诉用户当前阶段、要做什么、通过标准是什么
- 用户粘命令输出后：先判定"通过/失败"，再决定是否进入下一步
- 失败时：直接给故障预案对应条目，不让用户自己翻文档
- 完成后：必须输出闭环报告，否则视为未完成
````

把上面 ` ```markdown … ``` ` 之间的内容保存到对应 agent 的安装路径（参见上面"多 Agent 安装路径"表）：Claude Code 走 `~/.claude/skills/release-sop/SKILL.md`（含 frontmatter），其他 agent 各自规则。仓库源同步在 [`PeterGuy326/git-skill`](https://github.com/PeterGuy326/git-skill/blob/main/skills/release-sop/SKILL.md)，后续行为修订都会从仓库往这里反向同步。

---

## 14. 维护

- 本 SOP 是活文档，发现实操与 SOP 不符时：**改 SOP 或改实操，二选一，绝不放任**
- 重大流程变化（CI 平台迁移 / 新增分发渠道 / 工具大版本升级）必须同步更新 SOP 并升 SOP 版本号
- 每 N 个 release 复盘一次：失败次数、Captain 平均耗时、回滚次数

---

> **底层逻辑**：发布的本质不是"把代码推出去"，是"把承诺交付给用户"。SOP 让承诺可重复、可追溯、可回滚。Captain 不是按钮工，是承诺的 owner。
>
> 一句话钉死：**没闭环就没发布。**

---

## 附 — 相关链接

- 配套 skill 仓库：<https://github.com/PeterGuy326/git-skill>（`release-sop` 的源在 `skills/release-sop/SKILL.md`）
- 案例项目：<https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli>
- Keep a Changelog：<https://keepachangelog.com/>
- Semantic Versioning：<https://semver.org/>
- GoReleaser：<https://goreleaser.com/>
- Agent 文档：[Claude Code Skills](https://docs.claude.com/claude-code) / [Qoder](https://qoder.com/) / [Cursor Rules](https://docs.cursor.com/) / OpenAI Custom GPT
