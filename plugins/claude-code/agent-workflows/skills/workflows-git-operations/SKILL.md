---
name: workflows-git-operations
description: Use when an agent needs to perform or plan Git operations such as repository initialization, status/diff review, scoped staging, branch creation or switching, commit message generation, commit, pull, push, rollback, revert, reset, stash, or safe stale index.lock handling, especially when explicit user approval and Chinese Conventional Commit-style messages are required.
---

# Git Operations Workflow

Use this workflow whenever a task asks for repository initialization, Git state changes, commit message generation, or recovery from Git lock/index issues. Treat Git as a stateful collaboration surface: inspect first, scope precisely, and only mutate repository state inside the user's authorization boundary.

## Approval Boundary

- Read-only inspection is allowed without extra approval: `git status`, `git diff`, `git log`, `git show`, `git branch --show-current`, and similar commands that do not change refs, the index, or the working tree.
- State-changing operations require explicit user approval unless the current user request already grants it: `git init`, `git add`, `git commit`, `git pull`, `git fetch`, `git push`, `git merge`, `git rebase`, `git cherry-pick`, `git revert`, `git reset`, `git restore`, `git checkout`, `git switch`, branch creation, tag creation/deletion, branch deletion, `git stash`, and lock deletion.
- Treat approval as one-operation by default. Session-wide approval only exists when the user clearly says the current session may auto-commit, auto-push, or otherwise perform a named class of Git operation.
- Do not let one approval imply another class of operation. Approval to commit does not imply approval to push. Approval to stage does not imply approval to commit. Approval to pull does not imply approval to resolve conflicts destructively.
- For rollback-like work, ask for or confirm the target before changing state: exact file paths, commit hashes, branch names, or whether the user wants `revert`, `restore`, or `reset`.

## Standard Workflow

1. Identify the repository root and branch. If nested repos or submodules are involved, inspect each repo separately.
2. Run `git status --short --branch` and inspect the relevant diff before proposing or executing Git changes.
3. Separate task changes from unrelated dirty files. Do not stage untracked or modified files merely because they exist.
4. Stage with explicit paths whenever possible. Avoid `git add .` unless the user explicitly approved all current changes and the status was reviewed.
5. Before commit, review `git diff --cached --name-only` and the staged diff. Ensure the commit message matches the staged scope.
6. After commit, report the commit hash, subject, and remaining dirty/untracked state. After push, report branch and remote.

## Repository Initialization

- Repository initialization changes local state and requires approval unless the current user request explicitly asks to initialize the target directory as a Git repository.
- Resolve the target directory before initializing. If it is already inside a Git repository, stop and report the existing repository root instead of creating a nested repository unless the user explicitly asks for nesting.
- Default new repositories to `main` as the primary branch. Prefer `git init -b main`.
- If `git init -b main` is unavailable on older Git, run `git init`, then immediately rename the unborn/current branch with `git branch -M main`, and verify with `git branch --show-current`.
- After initialization, report the repository root and branch. Do not add a remote, stage files, commit, or push unless separately requested or approved.

Examples:

```powershell
git init -b main
git branch --show-current
```

## Commit Messages

Use:

```text
type(scope): 中文描述
```

Allowed `type` values:

```text
init: 初始化
feat: 新特性
fix: 修改问题
refactor: 代码重构
docs: 文档修改
style: 代码格式修改，不是 CSS 修改
test: 测试用例修改
build: 构建项目
chore: 其他修改，比如依赖管理
```

Commit message rules:

- Keep `scope` short and concrete, such as `route`, `component`, `utils`, `build`, `workflow`, `gateway`, or a compact module name.
- Write the subject in Chinese. Keep simple changes brief, with no trailing punctuation.
- Choose `type` from the actual staged diff, not from the user's initial wording.
- Use `docs` for documentation and skill text changes; use `chore` for dependency, metadata, generated housekeeping, or repository maintenance that does not fit another type.
- For broad or complex changes, keep the subject as the total summary and add a short body with `总:` and `分:`. Do not turn the body into a detailed changelog.

Examples:

```powershell
git commit -m 'fix(auth): 修复登录状态刷新'
git commit -m 'docs(workflow): 新增Git操作规范'
git commit -m 'refactor(gateway): 梳理连接生命周期' -m '总: 统一网关连接注册、断线清理和重连入口。
分: 调整链路管理、会话校验和关键回归测试。'
```

## Branch Creation

- Creating or switching branches changes repository state and requires approval, unless the user explicitly granted branch-operation approval for the current session.
- Before creating a branch, inspect the current branch, upstream, status, and intended base commit. Say which base the new branch will start from.
- Do not create or switch branches with unrelated dirty changes unless the user approved how to preserve them. Prefer committing, stashing, or staying on the current branch after explicit instruction.
- Use the operation type as the first branch path segment by default, such as `feat/`, `fix/`, `docs/`, `refactor/`, `test/`, `build/`, or `chore/`.
- Do not use agent/tool identity prefixes such as `codex/` unless the user, repository, or team convention explicitly requires them.
- Use short ASCII lower-kebab names after the type prefix. Avoid Chinese characters, spaces, punctuation-heavy names, ticket descriptions, and overly broad names.
- Prefer a shape like `<type>/<scope>-<short-topic>`, for example `feat/auth-login` or `fix/build-script`. If `scope` would be redundant, use `<type>/<short-topic>`.
- Keep `scope` compact and tied to the work area. Keep `short-topic` descriptive enough to identify the task, but not a sentence.
- Check whether the local branch already exists before creating it. If a branch name collides, ask before reusing, resetting, deleting, or force-updating it.
- Do not push or set upstream for a newly created branch unless push/upstream setup was separately approved.

Examples:

```powershell
git switch -c feat/auth-login
git switch -c fix/build-script
git switch -c docs/git-workflow
```

## Pull And Push

- Before `pull`, inspect branch, upstream, local dirty state, and whether the user expects merge, rebase, or fast-forward-only behavior.
- Do not pull into a dirty worktree unless the user approved the strategy for preserving local changes.
- If pull/merge/rebase creates conflicts, stop after reporting the conflicted files and ask before choosing a conflict resolution strategy.
- Before `push`, verify the branch, remote, upstream, and commits to be pushed. Report any unrelated local commits discovered in the push range.
- Never force-push unless the user explicitly approves that exact branch and remote.

## Rollback

- Prefer `git revert` for commits that may already be shared.
- Use path-scoped `git restore` for uncommitted file rollback only after confirming the exact files.
- Treat `git reset --hard`, `git clean`, branch deletion, and force push as high-risk operations requiring explicit, operation-specific approval.
- Before rollback, capture the current status and relevant commit hashes so the change can be audited.

## Safe index.lock Handling

During approved pull, fetch, stage, or commit work, it is allowed to delete an existing safe stale `index.lock` only when all conditions are true:

- The lock path is the exact target repo's `.git/index.lock`, resolved to an absolute path inside that repo's `.git` directory.
- No active Git process or IDE operation appears to be using that repository.
- The current operation already has user approval, or the user explicitly approved deleting that exact lock path.
- The lock existed before the retry and the same Git operation failed because of that lock.

Procedure:

1. Show the exact lock path and why it appears stale.
2. Check for active Git processes where practical.
3. Delete only that exact `index.lock` with a literal path command.
4. Retry the same scoped Git operation once.
5. If the lock returns or another lock/config/ref error appears, stop and report the evidence.

Do not delete other lock files by analogy, such as `config.lock`, `packed-refs.lock`, or nested repo locks, unless the user approves that exact path and the same safety checks pass.

## Final Report

Report what changed, which branch was created or switched when relevant, what was committed or pushed, the commit hash when available, any lock deletion performed, the validation run, and any remaining untracked or unrelated files. Clearly separate verified facts from assumptions.
