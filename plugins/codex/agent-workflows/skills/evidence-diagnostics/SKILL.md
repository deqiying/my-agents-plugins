---
name: evidence-diagnostics
description: Use for diagnosing repeated failures, conflicting evidence, source/generated/runtime or config/runtime mismatches, and high-rollback-risk decisions. Distinguish states, gather the minimum decisive evidence, and revise the path when new evidence appears. Do not use for ordinary multi-step tasks or as a substitute for a specialized tool.
---

# 证据驱动诊断

这是诊断与决策检查单，不规定 agent 的内部思考方式，也不要求固定步骤数或公开完整推理过程。

## 适用范围

- 同一问题已多次尝试仍失败，下一步必须由新证据决定。
- source、generated output、installed cache、config 与 runtime 行为可能不一致。
- 日志、测试、代码或用户描述彼此冲突，需要先确认真实状态。
- 迁移、广泛改动或其他高回滚成本操作前，需要确认影响范围和验证边界。

## 不适用

- 仅因任务复杂、模糊或包含多个步骤而触发；此类任务由 agent 自行规划，必要时使用 Plan mode。
- 已知文件的局部改动、简单查询，或成功条件明显的命令。
- 需要 current docs、semantic code search、browser automation、spreadsheet/document handling 等专用能力的任务；直接路由到相应 skill 或 MCP。

## 工作方式

按需执行以下检查，不补充无助于决策的仪式性步骤：

1. 明确要确认的行为、不可逆边界与最少所需证据。
2. 读取最接近问题的真实 source、config、log、test output 或 runtime 结果。
3. 当相似状态可能分离时分别验证，例如 source 与 generated output、config 文件与已加载配置、TCP/TLS/HTTP 层，或 build/test/runtime。
4. 选择能减少最大不确定性的最小下一步；新证据推翻假设时，缩小或修正路径，而不是沿用原计划。
5. 若进入工程改动，使用 `$guidelines` 控制改动范围，并执行与风险相称的最小验证。

## 输出

- 仅报告结论、关键证据、已排除的状态与剩余未验证边界；不要公开冗长的内部推理。
