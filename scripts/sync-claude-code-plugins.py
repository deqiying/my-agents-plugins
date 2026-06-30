#!/usr/bin/env python3
"""Sync Codex-maintained plugins into the Claude Code marketplace layout.

The repository keeps Codex plugin sources as the hand-maintained canonical
format. This script regenerates the Claude Code marketplace from that source.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


SCRIPT_NAME = "scripts/sync-claude-code-plugins.py"
STATE_FILE = ".sync-state.json"
CODEX_MARKETPLACE = ".agents/plugins/marketplace.json"
CODEX_PLUGIN_MANIFEST = ".codex-plugin/plugin.json"
CLAUDE_MARKETPLACE = ".claude-plugin/marketplace.json"
CLAUDE_PLUGIN_MANIFEST = ".claude-plugin/plugin.json"


def load_json(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise SystemExit(f"missing required file: {path}") from None
    except json.JSONDecodeError as exc:
        raise SystemExit(f"invalid JSON in {path}: {exc}") from None


def json_bytes(data: dict[str, Any]) -> bytes:
    return (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def adapt_metadata_text(value: Any) -> Any:
    if not isinstance(value, str):
        return value
    return value.replace("Codex", "Claude Code").replace("codex", "claude-code")


def adapt_keywords(values: Any) -> list[str]:
    if not isinstance(values, list):
        return []
    result: list[str] = []
    for item in values:
        if not isinstance(item, str):
            continue
        keyword = adapt_metadata_text(item)
        if keyword not in result:
            result.append(keyword)
    if "claude-code" not in result:
        result.append("claude-code")
    return result


def add_skill_tree(files: dict[str, bytes], source: Path, target: Path) -> None:
    if not source.is_dir():
        raise SystemExit(f"missing skills directory: {source}")

    ignored_names = {
        "__pycache__",
        ".DS_Store",
        ".git",
        ".codex-plugin",
        ".agents",
        "agents",
    }
    for path in source.rglob("*"):
        rel = path.relative_to(source)
        if any(part in ignored_names for part in rel.parts):
            continue
        if path.is_file() and not path.name.endswith(".pyc"):
            files[relative_posix(target / rel)] = path.read_bytes()


def build_plugin_manifest(codex_manifest: dict[str, Any]) -> dict[str, Any]:
    interface = codex_manifest.get("interface")
    if not isinstance(interface, dict):
        interface = {}

    manifest: dict[str, Any] = {
        "name": codex_manifest["name"],
        "version": codex_manifest["version"],
        "description": adapt_metadata_text(codex_manifest.get("description", "")),
    }

    display_name = interface.get("displayName")
    if isinstance(display_name, str) and display_name:
        manifest["displayName"] = display_name

    author = codex_manifest.get("author")
    if isinstance(author, dict):
        manifest["author"] = author
    elif isinstance(interface.get("developerName"), str):
        manifest["author"] = {"name": interface["developerName"]}
    else:
        manifest["author"] = {"name": "Maintainer"}

    for key in ("homepage", "repository", "license"):
        if key in codex_manifest:
            manifest[key] = codex_manifest[key]

    keywords = adapt_keywords(codex_manifest.get("keywords"))
    if keywords:
        manifest["keywords"] = keywords

    # Claude Code discovers skills by directory convention; keep this field as
    # a readable pointer for the generated manifest if the validator permits it.
    manifest["skills"] = "./skills/"
    return manifest


def build_marketplace_entry(plugin_name: str, codex_manifest: dict[str, Any], source_path: str) -> dict[str, Any]:
    interface = codex_manifest.get("interface")
    if not isinstance(interface, dict):
        interface = {}

    description = (
        interface.get("shortDescription")
        or codex_manifest.get("description")
        or f"{plugin_name} plugin"
    )
    entry: dict[str, Any] = {
        "name": plugin_name,
        "source": source_path,
        "version": codex_manifest.get("version", "0.0.0"),
        "description": adapt_metadata_text(description),
    }

    category = interface.get("category")
    if isinstance(category, str) and category:
        entry["category"] = category

    author = codex_manifest.get("author")
    if isinstance(author, dict):
        entry["author"] = author

    return entry


def codex_plugin_entries(codex_root: Path) -> list[dict[str, Any]]:
    marketplace = load_json(codex_root / CODEX_MARKETPLACE)
    plugins = marketplace.get("plugins")
    if not isinstance(plugins, list):
        raise SystemExit(f"{codex_root / CODEX_MARKETPLACE} must contain a plugins array")
    return plugins


def relative_posix(path: Path) -> str:
    return path.as_posix()


def collect_files(root: Path) -> dict[str, Path]:
    if not root.exists():
        return {}
    return {
        relative_posix(path.relative_to(root)): path
        for path in root.rglob("*")
        if path.is_file()
    }


def render_claude_files(codex_root: Path) -> tuple[dict[str, bytes], list[str]]:
    entries = codex_plugin_entries(codex_root)
    files: dict[str, bytes] = {}
    plugin_names: list[str] = []
    marketplace_plugins: list[dict[str, Any]] = []

    for entry in entries:
        if not isinstance(entry, dict):
            raise SystemExit("Codex marketplace plugin entries must be objects")
        plugin_name = entry.get("name")
        source = entry.get("source")
        if not isinstance(plugin_name, str) or not plugin_name:
            raise SystemExit("Codex marketplace plugin entry is missing name")
        if not isinstance(source, dict) or not isinstance(source.get("path"), str):
            raise SystemExit(f"Codex marketplace plugin {plugin_name} is missing source.path")

        codex_plugin_root = (codex_root / source["path"]).resolve()
        codex_manifest_path = codex_plugin_root / CODEX_PLUGIN_MANIFEST
        codex_manifest = load_json(codex_manifest_path)
        if codex_manifest.get("name") != plugin_name:
            raise SystemExit(
                f"plugin name mismatch: marketplace has {plugin_name}, "
                f"manifest has {codex_manifest.get('name')}"
            )

        skills_path = codex_manifest.get("skills")
        if not isinstance(skills_path, str) or not skills_path:
            raise SystemExit(f"{codex_manifest_path} must contain a skills path")

        files[relative_posix(Path(plugin_name) / CLAUDE_PLUGIN_MANIFEST)] = json_bytes(
            build_plugin_manifest(codex_manifest)
        )
        add_skill_tree(files, codex_plugin_root / skills_path, Path(plugin_name) / "skills")

        marketplace_plugins.append(
            build_marketplace_entry(plugin_name, codex_manifest, f"./{plugin_name}")
        )
        plugin_names.append(plugin_name)

    files[CLAUDE_MARKETPLACE] = json_bytes(
        {
            "name": "my-agents-plugins",
            "description": "Claude Code plugin marketplace mirrored from the Codex-maintained my-agents-plugins source tree.",
            "owner": {"name": "Maintainer"},
            "plugins": marketplace_plugins,
        }
    )

    managed_paths = [".claude-plugin", *plugin_names, STATE_FILE]
    files[STATE_FILE] = json_bytes(
        {
            "generatedBy": SCRIPT_NAME,
            "sourceRoot": "plugins/codex",
            "targetRoot": "plugins/claude-code",
            "managedPaths": managed_paths,
            "plugins": plugin_names,
        }
    )
    return files, managed_paths


def load_state(target_root: Path) -> dict[str, Any] | None:
    path = target_root / STATE_FILE
    if not path.exists():
        return None
    state = load_json(path)
    if state.get("generatedBy") != SCRIPT_NAME:
        raise SystemExit(f"refusing to use unknown sync state: {path}")
    return state


def existing_managed_paths(state: dict[str, Any] | None) -> set[str]:
    if not state:
        return set()
    paths = state.get("managedPaths")
    if not isinstance(paths, list):
        raise SystemExit(f"{STATE_FILE} has invalid managedPaths")
    return {path for path in paths if isinstance(path, str)}


def guard_initial_conflicts(target_root: Path, generated_paths: set[str], state: dict[str, Any] | None) -> None:
    if state:
        return
    conflicts = [path for path in sorted(generated_paths) if (target_root / path).exists()]
    if conflicts:
        formatted = "\n".join(f"  - {path}" for path in conflicts)
        raise SystemExit(
            "refusing to overwrite unmanaged Claude Code paths before a sync state exists:\n"
            f"{formatted}"
        )


def compare_generated(target_root: Path, generated_files: dict[str, bytes], generated_paths: set[str], state: dict[str, Any] | None) -> list[str]:
    diffs: list[str] = []
    previous_paths = existing_managed_paths(state)
    managed_roots = previous_paths | generated_paths

    all_target_files = collect_files(target_root)
    target_files = {
        rel: path
        for rel, path in all_target_files.items()
        if any(rel == root or rel.startswith(f"{root}/") for root in managed_roots)
    }

    for rel, content in sorted(generated_files.items()):
        target_path = target_root / rel
        if not target_path.exists():
            diffs.append(f"missing: {rel}")
        elif target_path.read_bytes() != content:
            diffs.append(f"changed: {rel}")

    for rel in sorted(target_files):
        if rel not in generated_files:
            diffs.append(f"stale: {rel}")

    return diffs


def sync_to_target(target_root: Path, generated_files: dict[str, bytes], generated_paths: set[str], state: dict[str, Any] | None) -> None:
    target_root.mkdir(parents=True, exist_ok=True)
    guard_initial_conflicts(target_root, generated_paths, state)

    for rel, content in sorted(generated_files.items()):
        target = target_root / rel
        if target.exists() and target.is_dir():
            raise SystemExit(f"refusing to overwrite directory with file: {target}")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)


def parse_args(argv: list[str]) -> argparse.Namespace:
    repo_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(
        description="Sync Codex plugin sources into Claude Code marketplace layout.",
    )
    parser.add_argument(
        "--codex-root",
        type=Path,
        default=repo_root / "plugins" / "codex",
        help="Codex marketplace root. Defaults to plugins/codex.",
    )
    parser.add_argument(
        "--claude-root",
        type=Path,
        default=repo_root / "plugins" / "claude-code",
        help="Claude Code marketplace root. Defaults to plugins/claude-code.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Fail if the Claude Code marketplace is not up to date.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print pending differences without writing files.",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    codex_root = args.codex_root.resolve()
    claude_root = args.claude_root.resolve()
    state = load_state(claude_root)

    generated_files, managed_path_list = render_claude_files(codex_root)
    managed_paths = set(managed_path_list)
    diffs = compare_generated(claude_root, generated_files, managed_paths, state)

    if args.check or args.dry_run:
        if diffs:
            print("Claude Code plugin mirror is out of sync:")
            for diff in diffs:
                print(f"  - {diff}")
            return 1 if args.check else 0
        print("Claude Code plugin mirror is up to date.")
        return 0

    sync_to_target(claude_root, generated_files, managed_paths, state)
    remaining_diffs = compare_generated(claude_root, generated_files, managed_paths, load_state(claude_root))
    if remaining_diffs:
        print("Claude Code plugin mirror still has stale or conflicting managed files:")
        for diff in remaining_diffs:
            print(f"  - {diff}")
        return 1
    print(
        "Synced Claude Code marketplace: "
        f"{len(managed_paths) - 2} plugins -> {claude_root}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
