# My Agents Plugins

这是一个多 agent 插件市场仓库，用于维护可复用的本地 workflow 插件、MCP 路由技能、OpenCLI 辅助技能和设计系统参考技能。

不同 agent 的插件市场格式不同，因此按 agent 分开维护：

- `plugins/codex/`: Codex 插件包源码。
- `plugins/claude-code/`: Claude Code 插件市场预留目录，当前暂未维护内容。

当前只有 Codex 插件市场可用。Codex CLI 的 marketplace root 是 `plugins/codex/`，入口文件位于 `plugins/codex/.agents/plugins/marketplace.json`。

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

## 插件说明

### Agent Workflows

`agent-workflows` 提供规划、工程约束、Git 操作纪律、密集输出整理、证据驱动思考和方案拷问相关的 workflow skills。

Skills:

- `workflows-grill-me`: 对设计或方案进行逐步追问和压力测试。
- `workflows-guidelines`: 约束非平凡工程改动保持简单、最小、可验证。
- `workflows-git-operations`: 规范 Git 检查、分支创建、暂存、提交、拉取、推送、回滚和安全锁处理。
- `workflows-output-formatting`: 将复杂技术回复整理成更容易阅读的结构，同时保留关键信息。
- `workflows-sequential-thinking`: 用于复杂排障、权衡分析和多步骤执行的结构化思考。

### Agent Utilities

`agent-utilities` 提供本机开发环境检查、初始化、更新和工具清单维护相关的辅助技能。

Skills:

- `setup-dev-env`: 检查、安装和更新本地开发环境的主入口，按平台串联 Scoop、mise、Homebrew 和工具清单技能。
- `manage-scoop`: Windows 专属，检查、安装和更新 Scoop，并作为 Windows 下 mise 的前置环境入口。
- `manage-mise`: 检查、安装和更新 mise 管理的语言运行时和 agent 常用工具。
- `manage-brew`: macOS 专属，检查、安装和更新 Homebrew 管理的开发工具。
- `maintain-dev-tool-list`: 维护 agent 开发常用工具、语言运行时和环境管理器的共享工具清单。

### Awesome DESIGN.md

`awesome-design-md` 打包 VoltAgent `awesome-design-md` 目录和辅助流程，用于选择并应用真实 `DESIGN.md` 设计参考。

Skill:

- `awesome-design-md`: 选择、获取并应用品牌风格设计指导。

### MCP Skills

`mcp-skills` 提供 MCP 服务的路由说明。它们只说明何时使用某个 MCP 服务，不替代用户本机的 MCP server 配置。

Skills:

- `mcp-context7`: 查询当前第三方库、框架、SDK 文档。
- `mcp-ddg-search`: 轻量网页检索和简单页面文本提取。
- `mcp-deepwiki`: 理解公开 GitHub 仓库的架构、模块和 API 面。
- `mcp-exa`: 按意图做语义网页发现和干净 markdown 提取。
- `mcp-excel-tools`: 检查和编辑 Excel 原生工作簿。
- `mcp-fast-context-mcp`: 用语义搜索定位本地代码库中的相关文件、入口点和影响范围。
- `mcp-firecrawl`: 做稳健网页抓取、结构化抽取、站点映射、爬取和文档解析。
- `mcp-freecrawl`: 做轻量公开搜索、简单抓取和小范围爬取。
- `mcp-tavily`: 处理新闻、政策、产品变化和需要多源验证的当前信息。

### OpenCLI

`opencli` 提供浏览器后端 CLI adapter 和登录态页面工作流相关技能。

Skills:

- `opencli-usage`: OpenCLI 顶层说明和命令发现入口。
- `opencli-browser`: 通过 OpenCLI 做临时浏览器自动化。
- `opencli-adapter-author`: 编写或扩展 OpenCLI 站点 adapter。
- `opencli-autofix`: 在 OpenCLI 命令失败后诊断并修复 adapter。
- `smart-search`: 将搜索和研究请求路由到合适的 OpenCLI 数据源。

### Tool Skills

`tool-skills` 提供本地 CLI 优先工作流说明。

Skill:

- `tool-codesearch`: 使用本地 `codesearch` CLI 在编辑前做语义代码库发现。
- `tool-officecli`: 使用本地 `officecli` CLI 创建、检查、修改、验证和渲染 Office 文档。

## 可移植性约定

插件 skill 文本不应包含机器相关绝对路径。文档和 skill 中请使用占位符：

- `<CODEX_HOME>`: 用户的 Codex home 目录，例如包含 `config.toml` 和 `plugins/` 的目录。
- `<AGENTS_HOME>`: 用户的 agents 目录，例如包含插件市场元数据的目录。
- `<PROJECTS_ROOT>`: 本地源码工作区根目录。
- `<REPO_ROOT>`: 当前插件市场仓库根目录。

在其他机器上使用这些插件时，只应在私有配置中替换占位符，不要把本机绝对路径提交到 skill 文本中。

## 维护检查

发布前建议检查：

1. `plugins/codex/.agents/plugins/marketplace.json` 可以被 JSON 解析。
2. 每个 `plugins/codex/*/.codex-plugin/plugin.json` 可以被 JSON 解析。
3. 已扫描 skill 文本，确认没有本机绝对路径或指定用户目录残留。
4. 安装或更新插件后，重启 Codex 或开启新会话以刷新插件缓存。
