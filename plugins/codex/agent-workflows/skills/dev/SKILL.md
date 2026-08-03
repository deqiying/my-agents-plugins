---
name: dev
description: Use when an agent needs a strict approval-gated workflow for a non-trivial software change that gathers evidence, selects an approach, presents a plan, waits for explicit approval, implements the approved scope, and verifies the result. Use when the user explicitly invokes $dev or asks for planning and confirmation before implementation. Do not use for simple answers, read-only reviews, or clear-scope changes the user wants completed directly.
---

# 开发工作流

使用本工作流时，以一次计划确认作为调查与实施之间的边界。它只约束当前任务；更高优先级指令、仓库规则和其他需要单独确认的操作仍然有效。

## 阶段

每次有实质内容的响应都以当前阶段标签开头：`[模式：研究]`、`[模式：方案]`、`[模式：计划]`、`[模式：实施]` 或 `[模式：验收]`。

### 研究

- 识别目标、范围、非目标、完成标准和风险边界。
- 在将假设视为事实前，检查相关指令、源码、配置、测试、日志和工作树。
- 仅当缺失信息会实质改变行为、接口、数据、安全性或交付范围，且无法安全推断时提问。
- 本阶段不修改文件。

### 方案

- 仅在备选方案会对正确性、范围、兼容性、风险或验证成本带来实质不同取舍时进行比较。
- 推荐有证据支撑的最小方案；一个路径已明显足够时，不虚构备选项。
- 简洁记录决策所需的事实、假设、取舍和建议。
- 本阶段不修改文件。

### 计划

- 说明预计影响的文件或代码区域、行为变化、按序实施步骤、验证方式、重要风险和假设。
- 首次呈现计划时，以 `请确认是否按此计划执行。` 结尾并停止。在用户明确确认前，不编辑文件、不运行可写命令，也不进入实施。
- 确认锁定目标、范围、对外行为、主要风险和验证标准，不锁定无害的实现细节。

### 实施

- 编辑前重新检查工作树，并保留无关的用户改动。
- 只实施已确认范围。对最小、聚焦、可验证的工程改动应用 `$guidelines`。
- 按受影响行为的风险运行相应验证。修复由本次改动导致的失败，并重复相关检查。
- 新证据若实质改变已确认的范围、行为、主要风险或验证标准，则回到 `[模式：计划]` 并重新请求确认。
- 对破坏性操作、外部写入、发布、部署、权限变更或敏感数据处理，单独请求确认。

### 验收

- 检查最终 diff 与工作树，排除无关改动、调试残留、意外泄露的敏感信息和不应提交的生成产物。
- 将结果与已确认计划和完成标准对照。
- 先报告结论，再说明已完成改动、已运行检查、计划偏离、未验证边界和剩余风险。

## 路由

- 出现重复失败、证据冲突、source/generated/runtime 状态不一致，或高回滚风险需要显式诊断时，使用 `$evidence-diagnostics`。
- 计划、验收结果或诊断报告包含多个决策或证据项时，使用 `$output-formatting`。
- 除非用户还要求访谈式设计讨论并希望沉淀术语或 ADR，否则不使用 `$grill-with-docs`。
