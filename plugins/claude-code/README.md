# Claude Code Plugins

此目录是 Claude Code 插件市场镜像，由仓库根目录的同步脚本从 `plugins/codex/` 生成。

## 维护方式

不要直接手工维护本目录下的插件内容。需要新增或修改插件、skill、`SKILL.md`、`references/`、`scripts/` 或 `assets/` 时，先修改 `plugins/codex/` 下的 Codex 风格维护源，然后运行：

```powershell
python scripts/sync-claude-code-plugins.py
```

检查 Claude Code mirror 是否和 Codex 源保持一致：

```powershell
python scripts/sync-claude-code-plugins.py --check
claude plugin validate plugins/claude-code --strict
```

## 目录格式

- `.claude-plugin/marketplace.json`: Claude Code marketplace 入口。
- `<plugin-name>/.claude-plugin/plugin.json`: Claude Code plugin manifest。
- `<plugin-name>/skills/`: 从 Codex plugin 的 `skills` 目录同步而来。

同步脚本不会复制 Codex/OpenAI 专用的 `agents/openai.yaml`。
