# Path Placeholders

Use placeholders instead of real local user directories in skill text, registry files, examples, reports intended for commit, and generated docs.

| Placeholder | Meaning |
| --- | --- |
| `<HOME>` | Current user's home directory. |
| `<CODEX_HOME>` | Codex home directory, such as the directory containing `config.toml`. |
| `<AGENTS_HOME>` | Agent marketplace/configuration home directory. |
| `<REPO_ROOT>` | Root of this plugin marketplace repository. |
| `<PROJECT_ROOT>` | Root of the project currently being prepared. |
| `<GLOBAL_MISE_CONFIG>` | Global mise config file, usually under the user's config directory. |
| `<LOCAL_MISE_CONFIG>` | Project-local `mise.toml` under `<PROJECT_ROOT>`. |
| `<MISE_DATA_DIR>` | mise data directory containing installed tools. |
| `<SCOOP_ROOT>` | User-level Scoop root on Windows. |
| `<SCOOP_GLOBAL>` | Global Scoop root on Windows, when used. |
| `<BREW_PREFIX>` | Homebrew prefix on macOS. |

When command output contains an absolute path, summarize the relevant fact and replace the path before writing it into a tracked file.
