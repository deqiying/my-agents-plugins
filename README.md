# My Agents Plugins

这是一个多 agent 插件市场仓库，用于维护可复用的本地 workflow 插件、MCP 路由技能、OpenCLI 辅助技能和设计系统参考技能。

不同 agent 的插件市场格式不同，因此按 agent 分开维护：

- `plugins/codex/`: Codex 插件包源码，也是本仓库的手工维护源。
- `plugins/claude-code/`: Claude Code 插件市场镜像，由同步脚本从 `plugins/codex/` 生成。

Codex CLI 的 marketplace root 是 `plugins/codex/`，入口文件位于 `plugins/codex/.agents/plugins/marketplace.json`。Claude Code 的 marketplace root 是 `plugins/claude-code/`，入口文件位于 `plugins/claude-code/.claude-plugin/marketplace.json`。

## 添加插件市场

在 Codex CLI 中，可以把 `plugins/codex` 目录添加为 Codex 插件市场来源：

```powershell
codex plugin marketplace add <repo-root>/plugins/codex
```

如果从 GitHub 使用，先 checkout 或 sparse checkout 仓库，再添加本地的 `plugins/codex` 目录：

```powershell
git clone https://github.com/<owner>/my-agents-plugins.git
codex plugin marketplace add ./my-agents-plugins/plugins/codex
```

如果使用 sparse checkout，需要包含 marketplace 元数据和插件目录：

```powershell
git clone --filter=blob:none --sparse https://github.com/<owner>/my-agents-plugins.git
cd my-agents-plugins
git sparse-checkout set plugins/codex
codex plugin marketplace add ./plugins/codex
```

Codex 插件市场元数据位于 `plugins/codex/.agents/plugins/marketplace.json`，Codex 插件源码位于 `plugins/codex/<plugin-name>/`。

## 同步 Claude Code 插件市场

手工维护 Codex 风格目录，然后运行脚本生成 Claude Code 风格目录：

```powershell
python scripts/sync-claude-code-plugins.py
python scripts/sync-claude-code-plugins.py --check
```

脚本会读取 `plugins/codex/.agents/plugins/marketplace.json` 和每个 `plugins/codex/<plugin-name>/.codex-plugin/plugin.json`，生成：

- `plugins/claude-code/.claude-plugin/marketplace.json`
- `plugins/claude-code/<plugin-name>/.claude-plugin/plugin.json`
- `plugins/claude-code/<plugin-name>/skills/...`

同步时会保留 `SKILL.md`、`references/`、`scripts/`、`assets/` 等 skill 内容，但不会复制 `agents/openai.yaml`，因为它是 Codex/OpenAI 专用的 UI metadata。不要直接手工维护 `plugins/claude-code/<plugin-name>/`，需要变更时先改 `plugins/codex/`，再重新运行同步脚本。

不适用于 Claude Code 的内容在 `scripts/claude-code-sync.json` 中声明：`excludePlugins` 排除整个插件，`excludeSkills` 按插件名排除单个 skill。同步会从既有镜像删除已排除的受管文件；配置中引用不存在的插件或 skill 会报错，避免拼写错误被静默忽略。可通过 `--config <path>` 为临时或验证场景指定其他配置文件。

在 Claude Code 中添加本地 marketplace：

```powershell
claude plugin marketplace add <repo-root>/plugins/claude-code
```

安装插件示例：

```powershell
claude plugin install agent-workflows@my-agents-plugins
```

## 插件说明

### Agent Workflows

`agent-workflows` 提供规划、工程约束、Git 操作纪律、密集输出整理、证据驱动思考和可沉淀文档的方案拷问相关的 workflow skills。

Skills:

- `workflows-grill-with-docs`: 自适应地逐题深挖或分批追问设计与方案，并在目标仓库中按需沉淀术语表与 ADR。
- `workflows-evidence-diagnostics`: 用于反复失败、证据冲突、状态不一致与高回滚成本改动的证据驱动诊断。
- `workflows-guidelines`: 以最小改动、风险分级和可验证性约束非平凡工程改动。
- `workflows-git-operations`: 规范 Git 仓库初始化、分支创建、检查、暂存、提交、拉取、推送、回滚和安全锁处理。
- `workflows-output-formatting`: 将复杂技术回复整理成更容易阅读的结构，同时保留关键信息。

### Agent Utilities

`agent-utilities` 将开发环境能力收敛到一个主 Skill，并把平台与管理器流程作为该 Skill 内部按需读取的参考资料维护。


Skills:

- `maintain-dev-env`: 唯一的开发环境 Skill，统一处理 Java/JDK、Maven/mvnd 及其他本地工具链的环境检查、设置、修复和任务阻塞问题。
- `curate-codex-memory`: 审计 Codex 长期记忆并生成授权的 ad-hoc 变更请求，不直接修改生成态记忆文件。

`maintain-dev-env` 内部通过 `references/scoop.md`、`references/mise.md`、`references/brew.md` 和 `references/tool-registry.md` 路由专用流程；这些文件不是独立 Skill。

### Awesome DESIGN.md

`awesome-design-md` 打包 VoltAgent `awesome-design-md` 目录和辅助流程，用于选择并应用真实 `DESIGN.md` 设计参考。

Skill:

- `awesome-design-md`: 选择、获取并应用品牌风格设计指导。


### OpenCLI

`opencli` 只打包 OpenCLI 工作流技能和界面元数据，不再内置上游源码或二进制；本地缺少 CLI 时，由 `opencli-usage` 引导通过 `npm install -g @jackwener/opencli@latest` 安装。

Skills:

- `opencli-usage`: 检测或安装 OpenCLI，并作为顶层说明和命令发现入口。
- `opencli-browser`: 通过 OpenCLI 做临时浏览器自动化。
- `opencli-browser-sitemap`: 在浏览器任务中按需使用 OpenCLI sitemap 导航和恢复上下文。
- `opencli-sitemap-author`: 创建、维护和验证 OpenCLI 站点 sitemap。
- `opencli-adapter-author`: 编写或扩展 OpenCLI 站点 adapter。
- `opencli-autofix`: 在 OpenCLI 命令失败后诊断并修复 adapter。
- `smart-search`: 将搜索和研究请求路由到合适的 OpenCLI 数据源。

### Onesearch

`onesearch` 提供 Onesearch CLI 的主路由技能，用于网页搜索、当前信息、URL 读取、官方文档、站点抓取和公开 GitHub 仓库上下文。插件只维护主技能，具体 provider 或 workflow 指南由本地 CLI 的 `onesearch skills list` / `onesearch skills show <route-id> --format content` 提供。

Skill:

- `onesearch`: 使用 Onesearch CLI 做 source-backed web research、fetch、docs、crawl、repo wiki 和 provider-specific workflows。

### Tool Skills

`tool-skills` 提供本地 CLI 优先工作流说明。

Skill:

- `tool-fast-context`: 未知入口场景首选的语义搜索 CLI，用于定位本地代码库中的相关文件、入口点和影响范围；在 skill 已加载且 `doctor` 预检通过后执行搜索，并在本地验证候选结果。
- `tool-officecli`: 优先使用本地 `officecli` CLI 读取、提取、检查、修改、验证和渲染 Office 文档。

## 可移植性约定

插件 skill 文本不应包含机器相关绝对路径。文档和 skill 中请使用占位符：

- `<CODEX_HOME>`: 用户的 Codex home 目录，例如包含 `config.toml` 和 `plugins/` 的目录。
- `<CLAUDE_HOME>`: 用户的 Claude Code home 目录，例如包含 Claude Code 配置、插件和技能的目录。
- `<AGENTS_HOME>`: 用户的 agents 目录，例如包含插件市场元数据的目录。
- `<PROJECTS_ROOT>`: 本地源码工作区根目录。
- `<REPO_ROOT>`: 当前插件市场仓库根目录。

在其他机器上使用这些插件时，只应在私有配置中替换占位符，不要把本机绝对路径提交到 skill 文本中。

## 维护检查

发布前建议检查：

1. `plugins/codex/.agents/plugins/marketplace.json` 可以被 JSON 解析。
2. 每个 `plugins/codex/*/.codex-plugin/plugin.json` 可以被 JSON 解析。
3. `python scripts/sync-claude-code-plugins.py --check` 通过，确认 Claude Code mirror 没有漂移。
4. `claude plugin validate plugins/claude-code --strict` 通过。
5. 已扫描 skill 文本，确认没有本机绝对路径或指定用户目录残留。
6. 安装或更新插件后，重启 Codex 或 Claude Code，或开启新会话以刷新插件缓存。
