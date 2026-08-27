# dws Ch.2 配套 GIF 录制脚手架

博文 `source/_posts/dws-getting-started-ch02.md` 里 4 个 `![](.gif)` 占位的源。

## TL;DR — 录 GIF

**默认路线 (asciinema + agg,零 chrome 依赖,Linux/WSL/服务器友好)**:

```bash
# 一次性装好
pip3 install --user asciinema
curl -fL -o ~/.local/bin/agg \
  https://github.com/asciinema/agg/releases/latest/download/agg-x86_64-unknown-linux-musl
chmod +x ~/.local/bin/agg
export PATH=$HOME/.local/bin:$PATH

# 录
cd scripts/dws-ch02-gifs
make all                 # 出 4 个 GIF 到 ../../source/img/dws-ch02/
```

**备用路线 (vhs,要 macOS 或装了真 Linux chromium 的环境)**:

```bash
brew install vhs
make all-vhs
```

## 两条路线怎么选

| | asciinema + agg | vhs |
|---|---|---|
| 依赖 | Python(asciinema) + Rust binary(agg) | Go binary + ttyd + ffmpeg + **真 chromium** |
| 总下载量 | ~16 MB | ~200 MB+ (chromium 占大头) |
| WSL2 | ✅ | ❌ chrome wrapper 是 Windows chrome,不能给 headless 用 |
| 服务器/CI | ✅ | ❌ 一般没 chrome |
| macOS / Linux 桌面 | ✅ | ✅ |
| GIF 帧率/质量 | swash 渲染,够用 | chromium 渲染,略精细 |

**选择**:默认 `make all` 走 asciinema+agg,通吃所有环境。除非你确定环境里有真 chromium 且要 vhs 的更精细渲染,才走 `make all-vhs`。

## 文件

| 文件 | 干啥用 |
|---|---|
| `prelude.sh` | 两路线共用的对话气泡函数 (`user_say`/`claude_say`/`cmd_run`/`out` 等) |
| `scene{1-4}-*.sh` | asciinema+agg 路线的 driver shell |
| `scene{1-4}-*.tape` | vhs 路线的录制脚本 |
| `Makefile` | `make all` (默认 agg) / `make all-vhs` / `make scene1-calendar` 单录 |

## 当前是 mock 输出 (开箱即用)

driver `.sh` 和 `.tape` 里 `dws ...` 命令旁边的 JSON 输出**全是写死的 mock**:

- ✅ 不依赖 dws 登录状态,谁都能跑
- ✅ 不会真发群消息 / 真批审批 / 真发周报
- ✅ 每次录出的 GIF 内容一致

## 想换成"真 dws 实跑"输出

只读场景(calendar 查询、todo 列表、template 查询、chat search、approval list-pending/detail/tasks)可以安全替换成真命令。

**asciinema+agg 路线** — 改 `scene*.sh` 里对应行,把 `cmd_run "..."` + `out '...'` 两行替换成真命令:

```bash
# 改前 (mock):
cmd_run "dws calendar event list --start ... --jq '.result.events'"
sleep 0.5
out '[{"summary":"晨会"...}]'

# 改后 (真跑):
dws calendar event list --start 2026-05-23T00:00:00+08:00 --end 2026-05-23T23:59:59+08:00 --format json --jq '.result.events'
sleep 1.5
```

⚠️ **写操作千万别真跑**:`report create` / `chat message send` / `oa approval approve` 这 3 条留 mock,否则你的群和审批流会被你自己测炸。

## 调节奏 / 尺寸 / 主题

**asciinema+agg 路线** — 改 Makefile 顶部:

```makefile
AGG_FONT_SIZE := 18           # 字号 (px)
AGG_THEME     := monokai      # 主题; 可选: asciinema/dracula/github-dark/kanagawa/nord/solarized-dark/gruvbox-dark
ROWS_scene1-calendar := 22    # 该场画布行数
COLS                 := 110   # 列数
```

每场 driver `.sh` 里 `sleep N` 控制节奏。

**vhs 路线** — 改各 `.tape` 顶部 `Set FontSize / Width / Height / Theme / TypingSpeed / Padding`,每段 `Sleep` 控停顿。

## 故障排查

```bash
# WSL2 跑 vhs: "could not launch browser"
which google-chrome
# /home/you/.local/bin/google-chrome  ← 如果指向一个 shell 脚本而非真 chrome,就是 WSL→Win Chrome wrapper
file $(which google-chrome)
# Bourne-Again shell script  ← 这就是坑根源, vhs 没法用
# 解决: 走默认的 asciinema+agg 路线 (make all),它不要 chrome

# GitHub release / brew 下载抖断 (libxrender SSL EOF / chromium 中途断)
# curl 加这套 flag 就稳:
curl --http1.1 --retry 10 --retry-all-errors --retry-delay 2 -fL -C - -o file URL

# agg 警告 "Failed to load font face from .ttf"
# 通常无害, fontconfig 会自动 fallback; 字渲染正常就忽略
# 要消警告: 显式指定字体 --text-font-family "DejaVu Sans Mono"

# GIF 中文显示豆腐方块
sudo apt install fonts-noto-cjk    # 装个 CJK 字体
# 或显式指定: agg --text-font-family "DejaVu Sans Mono,Noto Sans CJK SC" ...
```
