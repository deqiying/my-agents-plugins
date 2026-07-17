# 仓库规范

> 适用范围：当前项目仓库。

## 一、命名与职责边界

### Plugin 命名与归属

- plugin 目录和 `.codex-plugin/plugin.json` 的 `name` 应按其提供的能力类别命名，例如 `tool-skills`、`mcp-skills`、`agent-workflows` 或 `agent-utilities`；不要仅因位置相邻，就将无关类别的 skill 混入现有 plugin。
- plugin 和 skill 名称使用小写连字符形式；目录名、manifest 名、`SKILL.md` frontmatter 中的 `name`，以及 `agents/openai.yaml` 里的 `$skill-name` 提示词必须保持一致。

### Skill 命名

- `tool-skills` 中的 skill 用于封装普通本地 CLI 工具，必须使用 `tool-<tool-id>` 形式的名称，例如 `tool-codesearch` 或 `tool-officecli`。
- `mcp-skills` 中的 skill 用于路由 MCP server，必须使用 `mcp-<server-id>` 形式的名称，例如 `mcp-context7`。
- `agent-workflows` 中的 skill 用于描述可复用的 agent workflow，必须使用 `workflows-<workflow-id>` 形式的名称。
- `utility skill` 应使用与 plugin 领域匹配、以动词开头且含义明确的名称，例如 `setup-*`、`manage-*` 或 `maintain-*`。
- 当仓库封装层需要类别前缀时，不要向分类 plugin 添加不带前缀的上游 skill 名称。描述 `onesearch skills show onesearch-cli` 等命令时，只能在 skill 正文或参考资料中保留上游或 CLI 原生的 skill 名称。

## 二、Skill 路由与元数据

- 默认将 `SKILL.md` frontmatter 的 `description` 和面向触发的 metadata 写成 agent-neutral 的路由文本。该仓库是可复用的多 agent plugin 与 skill 集合，因此应优先使用 “Use when an agent needs”、“Use when the task involves” 或 “Use for” 等表述，而非 “when <product> needs” 这类产品绑定措辞。
- 仅当 skill 实际操作 `Codex`、`Claude Code`、OpenAI 或其他产品本身、其配置、marketplace、app、CLI 或产品专属 UI metadata 时，才可在 skill 描述中提及它们。不要将 `Codex` 当作消费该 skill 的 agent 的同义词。
- 触发描述必须具体并以能力为中心：说明 skill 的作用、应触发它的任务场景、重要的文件/工具/数据线索，以及必要时的关键排除项。不要依赖正文中的 “when to use” 小节作为路由依据，因为正文只会在 skill 触发后才加载。
- `SKILL.md` YAML frontmatter 的 `description` 默认不加引号，并使用 YAML plain scalar 写法；其中的冒号必须使用半角 `:`。仅当内容包含 `: ` 等会使 plain scalar 无法被 YAML 正确解析的序列时，才添加双引号。
- `SKILL.md` 正文可以使用全角引号等中文标点；该规则不适用于 YAML frontmatter。

## 三、维护与同步

### Plugin 注册

- 新增 plugin 目录时，必须在同一改动中将该 plugin 注册到相关 marketplace 条目。对 Codex，更新 `plugins/codex/.agents/plugins/marketplace.json`；当仓库根 marketplace 用于安装或兼容时，也更新 `.agents/plugins/marketplace.json`。

### 源文件与镜像

- 更新触发描述时，保持 `SKILL.md` frontmatter、`agents/openai.yaml` 提示词及相关 plugin interface metadata 一致。先编辑作为维护源的 `plugins/codex`，再通过同步脚本重新生成 `plugins/claude-code`，不要手工编辑镜像或其生成的 marketplace，例如 `plugins/claude-code/.claude-plugin/marketplace.json`。

### 版本与资源

- 新增或实质性更新 plugin，或其中任一 skill 时，必须在同一改动中递增其所属 `.codex-plugin/plugin.json` 的 `version`，并验证 package/marketplace 条目仍指向预期 plugin。采用最小合适的 semver 增量：skill 文档、metadata、资源或兼容的命令指南使用 patch；新增 skill、新增 plugin 能力或影响兼容性的 workflow 变更使用 minor；仅在有意引入破坏性变更时使用 major。
- 新增或实质性更新 plugin 或 skill 时，除非用户明确缩小范围，否则也应在同一改动中更新面向用户的 metadata 和视觉资源。
- 对 skill，默认新增或更新 `agents/openai.yaml` 和 `assets/icon.png`；当图标适合用确定性的 vector 表达时，保留可编辑的 `assets/icon.svg` 源文件。
- 对 plugin，默认检查 `.codex-plugin/plugin.json` 引用；适用时保持 `assets/icon.png`、`assets/logo.png` 和可编辑 SVG 源文件同步。
- 小型 UI 图标优先使用确定性的仓库原生 SVG/PNG 资源。只有在资源确实需要 raster 插画、纹理或无法用 vector 清晰表达的视觉概念时，才使用 AI image generation。

## 四、本机安装状态边界

- 常规仓库修改时，不要刷新操作者本机 Codex、Claude Code 或其他已安装 `my-agents-plugins` 的 marketplace/cache 状态。日常工作仅限仓库源文件、生成镜像、验证和可选提交。
- 仅当用户明确要求本机安装测试或 cache 刷新时，才运行 `codex plugin add`、`codex plugin marketplace add`、cachebuster/reinstall 辅助工具、cache 清理或本机产品刷新流程。

## 五、完成前检查

- 资源变更后，完成前验证被引用的路径存在，并扫描是否包含机器专属的绝对路径。
