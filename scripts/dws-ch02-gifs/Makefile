# dws Ch.2 配套 GIF 录制
# 两条路:
#   make all       默认走 asciinema+agg (零 chrome 依赖, Linux/WSL 友好)
#   make all-vhs   走 vhs (macOS 等有 Linux chromium 的环境)

SCENES  := scene1-calendar scene2-report scene3-chat scene4-oa
OUT_DIR := ../../source/img/dws-ch02
GIFS    := $(addprefix $(OUT_DIR)/,$(addsuffix .gif,$(SCENES)))

# agg 渲染参数
AGG_FONT_SIZE := 18
AGG_THEME     := monokai

# 每场画布行数 (asciinema rec --rows)
ROWS_scene1-calendar := 22
ROWS_scene2-report   := 30
ROWS_scene3-chat     := 24
ROWS_scene4-oa       := 36
COLS                 := 110

.PHONY: all all-agg all-vhs clean check-agg check-vhs help $(SCENES)

# === 默认 = asciinema + agg ===
all: all-agg

all-agg: check-agg $(GIFS)
	@echo ""
	@echo "✓ 4 个 GIF 已生成到 $(OUT_DIR)/"
	@ls -lh $(GIFS) 2>/dev/null | awk '{print "  " $$9 " (" $$5 ")"}'

# 单独录某一场: make scene1-calendar
$(SCENES): %: $(OUT_DIR)/%.gif

# 用 asciinema 录 cast → agg 转 gif
$(OUT_DIR)/%.gif: %.sh prelude.sh
	@mkdir -p $(OUT_DIR)
	@echo "→ 录 $* (rows=$(ROWS_$*), cols=$(COLS))"
	@asciinema rec --command "bash $<" --rows $(ROWS_$*) --cols $(COLS) --overwrite /tmp/$*.cast >/dev/null 2>&1
	@agg --font-size $(AGG_FONT_SIZE) --theme $(AGG_THEME) /tmp/$*.cast $@ 2>&1 | tail -1

check-agg:
	@command -v asciinema >/dev/null 2>&1 || { \
	  echo "✗ asciinema 没装。装一下:"; \
	  echo "    pip3 install --user asciinema"; \
	  exit 1; \
	}
	@command -v agg >/dev/null 2>&1 || { \
	  echo "✗ agg 没装。下载预编译 binary:"; \
	  echo "    curl -fL -o ~/.local/bin/agg https://github.com/asciinema/agg/releases/latest/download/agg-x86_64-unknown-linux-musl"; \
	  echo "    chmod +x ~/.local/bin/agg"; \
	  exit 1; \
	}
	@echo "✓ asciinema $$(asciinema --version 2>&1 | awk '{print $$2}'),  agg $$(agg --version 2>&1 | awk '{print $$2}')"

# === 备用 = vhs (要真 Linux chromium, 见 README 关于 WSL2 的注意事项) ===
all-vhs: check-vhs $(addprefix $(OUT_DIR)/_vhs-,$(addsuffix .gif,$(SCENES)))
	@echo "✓ vhs 路线完成 (输出文件名带 _vhs- 前缀,避免覆盖默认路线产物)"

$(OUT_DIR)/_vhs-%.gif: %.tape prelude.sh
	@mkdir -p $(OUT_DIR)
	vhs $<
	@mv $(OUT_DIR)/$*.gif $@

check-vhs:
	@command -v vhs >/dev/null 2>&1 || { \
	  echo "✗ vhs 没装。装一下:  brew install vhs"; \
	  exit 1; \
	}
	@echo "✓ vhs $$(vhs --version 2>&1 | head -1)"

clean:
	rm -f $(GIFS) $(addprefix $(OUT_DIR)/_vhs-,$(addsuffix .gif,$(SCENES)))

help:
	@echo "make / make all       默认: asciinema+agg 录 4 个 GIF"
	@echo "make all-vhs          备用: vhs 路线 (要真 Linux chromium)"
	@echo "make scene1-calendar  单录一场 (asciinema+agg)"
	@echo "make clean            删掉已生成 GIF"
	@echo "make check-agg        检查 asciinema/agg"
	@echo "make check-vhs        检查 vhs"
