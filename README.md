# My Codex Plugins

这是一个 Codex 插件市场仓库，用于维护可复用的本地 workflow 插件、MCP 路由技能、OpenCLI 辅助技能和设计系统参考技能。

## 添加插件市场

在 Codex CLI 中，可以把仓库根目录添加为插件市场来源：

```powershell
codex plugin marketplace add <repo-url-or-local-path>
```

如果发布到 GitHub，可以固定分支或 tag：

```powershell
codex plugin marketplace add <owner>/my-codex-plugins --ref main
```

如果使用 sparse checkout，需要包含 marketplace 元数据和插件目录：

```powershell
codex plugin marketplace add https://github.com/<owner>/my-codex-plugins.git --sparse .agents/plugins --sparse plugins --ref main
```

插件市场元数据位于 `.agents/plugins/marketplace.json`，插件源码位于 `plugins/`。

## 插件说明

### Agent Workflows

`agent-workflows` 提供规划、工程约束、密集输出整理、证据驱动思考和方案拷问相关的 workflow skills。

Skills:

- `workflows-grill-me`: 对设计或方案进行逐步追问和压力测试。
- `workflows-guidelines`: 约束非平凡工程改动保持简单、最小、可验证。
- `workflows-output-formatting`: 将复杂技术回复整理成更容易阅读的结构，同时保留关键信息。
- `workflows-sequential-thinking`: 用于复杂排障、权衡分析和多步骤执行的结构化思考。

### Awesome DESIGN.md

`awesome-design-md` 打包 VoltAgent `awesome-design-md` 目录和辅助流程，用于选择并应用真实 `DESIGN.md` 设计参考。

Skill:

- `awesome-design-md`: 选择、获取并应用品牌风格设计指导。

### MCP Skills

`mcp-skills` 提供 MCP 服务的路由说明。它们只说明何时使用某个 MCP 服务，不替代用户本机的 MCP server 配置。

Skills:

- `mcp-ace-tool`: 按业务行为、工作流或影响面做语义代码检索。
- `mcp-context7`: 查询当前第三方库、框架、SDK 文档。
- `mcp-ddg-search`: 轻量网页检索和简单页面文本提取。
- `mcp-deepwiki`: 理解公开 GitHub 仓库的架构、模块和 API 面。
- `mcp-exa`: 按意图做语义网页发现和干净 markdown 提取。
- `mcp-excel-tools`: 检查和编辑 Excel 原生工作簿。
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

## 可移植性约定

插件 skill 文本不应包含机器相关绝对路径。文档和 skill 中请使用占位符：

- `<CODEX_HOME>`: 用户的 Codex home 目录，例如包含 `config.toml` 和 `plugins/` 的目录。
- `<AGENTS_HOME>`: 用户的 agents 目录，例如包含插件市场元数据的目录。
- `<PROJECTS_ROOT>`: 本地源码工作区根目录。
- `<REPO_ROOT>`: 当前插件市场仓库根目录。

在其他机器上使用这些插件时，只应在私有配置中替换占位符，不要把本机绝对路径提交到 skill 文本中。

## 维护检查

发布前建议检查：

1. `.agents/plugins/marketplace.json` 可以被 JSON 解析。
2. 每个 `plugins/*/.codex-plugin/plugin.json` 可以被 JSON 解析。
3. 已扫描 skill 文本，确认没有本机绝对路径或指定用户目录残留。
4. 安装或更新插件后，重启 Codex 或开启新会话以刷新插件缓存。
