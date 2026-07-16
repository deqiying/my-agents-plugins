#!/usr/bin/env python3
"""Read-only Codex memory audit and safe ad-hoc note generation."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Iterable, Sequence


SEVERITY_ORDER = {"high": 0, "medium": 1, "low": 2}
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
BULLET_RE = re.compile(r"^\s*[-*]\s+(.+?)\s*$")
ROLLOUT_RE = re.compile(r"rollout_summaries[\\/][^\s`)>,]+?\.md", re.IGNORECASE)
THREAD_ID_RE = re.compile(
    r"\bthread_id\s*=\s*([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\b",
    re.IGNORECASE,
)
DATE_RE = re.compile(r"\b(20\d{2})-(0[1-9]|1[0-2])-([0-2]\d|3[01])\b")
DRIFT_RE = re.compile(
    r"\b(latest|current|today|pricing|release|version|endpoint|timeline|public availability)\b"
    r"|当前|最新|现在|截至|版本|价格|已发布",
    re.IGNORECASE,
)
SNAPSHOT_LABEL_RE = re.compile(
    r"^\s*(?:[-*]\s*)?revalidation\s*:\s*.*(?:\bsnapshot\b|快照)"
    r"|^\s*(?:[-*]\s*)?(?:snapshot|快照)\s*(?:$|[|:])",
    re.IGNORECASE,
)
LINE_REVALIDATION_RE = re.compile(
    r"\b(re-?check|revalidate(?:\s+before\s+use)?|dated|as of)\b"
    r"|revalidation\s*:\s*(?:durable|re-?check before use)"
    r"|复核|重新检查|截至",
    re.IGNORECASE,
)
SECRET_ASSIGNMENT_RE = re.compile(
    r"\b(api[_-]?key|client[_-]?secret|secret|password|private[_-]?key|bearer|token|cookie|connection[_-]?string)"
    r"\s*[:=]\s*([^\s,;]+)",
    re.IGNORECASE,
)
BEARER_RE = re.compile(r"authorization\s*:\s*bearer\s+([^\s,;]+)", re.IGNORECASE)
URL_SECRET_RE = re.compile(
    r"[?&](api[_-]?key|token|access_token|key)=([^\s&#]+)",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class LineContext:
    group: str = ""
    task: str = ""
    section: str = ""


@dataclass(frozen=True)
class Finding:
    severity: str
    kind: str
    line: int
    detail: str
    group: str = ""
    task: str = ""


def default_memory_root() -> Path:
    codex_home = os.environ.get("CODEX_HOME")
    base = Path(codex_home).expanduser() if codex_home else Path.home() / ".codex"
    return base / "memories"


def _normalize_heading(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().casefold())


def _normalize_bullet(value: str) -> str:
    value = re.sub(r"`([^`]*)`", r"\1", value)
    value = re.sub(r"\s+", " ", value.strip().casefold())
    return value.strip(" .,:;，。；：")


def _is_task_heading(value: str) -> bool:
    return re.match(r"^task\s+\d+\s*:", value.strip(), re.IGNORECASE) is not None


def _is_group_heading(value: str) -> bool:
    return value.strip().casefold().startswith("task group:")


def _looks_redacted(value: str) -> bool:
    cleaned = value.strip("'\"()[]{}<>.,;:").casefold()
    if not cleaned:
        return True
    if any(marker in value.casefold() for marker in ("<redacted>", "...", "example.invalid")):
        return True
    if cleaned in {"redacted", "masked", "placeholder", "none", "null", "changeme"}:
        return True
    return re.fullmatch(r"[x*_-]{4,}", cleaned) is not None


def _secret_kinds(line: str) -> list[str]:
    kinds: list[str] = []
    for match in SECRET_ASSIGNMENT_RE.finditer(line):
        if not _looks_redacted(match.group(2)):
            kinds.append("possible-secret")
    for match in BEARER_RE.finditer(line):
        if not _looks_redacted(match.group(1)):
            kinds.append("possible-secret-in-header")
    for match in URL_SECRET_RE.finditer(line):
        if not _looks_redacted(match.group(2)):
            kinds.append("possible-secret-in-url")
    return sorted(set(kinds))


def _parse_contexts(
    lines: Sequence[str],
) -> tuple[
    list[LineContext],
    dict[tuple[tuple[str, ...], str], list[int]],
    dict[str, list[int]],
    set[str],
    set[tuple[str, str]],
]:
    contexts: list[LineContext] = []
    heading_occurrences: dict[tuple[tuple[str, ...], str], list[int]] = defaultdict(list)
    group_lines: dict[str, list[int]] = defaultdict(list)
    group_revalidation: set[str] = set()
    task_revalidation: set[tuple[str, str]] = set()
    heading_stack: list[tuple[int, str]] = []
    group = ""
    task = ""
    section = ""

    for index, line in enumerate(lines):
        heading_match = HEADING_RE.match(line)
        if heading_match:
            level = len(heading_match.group(1))
            heading = heading_match.group(2).strip()
            while heading_stack and heading_stack[-1][0] >= level:
                heading_stack.pop()
            parent = tuple(item[1] for item in heading_stack)
            heading_occurrences[(parent, _normalize_heading(heading))].append(index + 1)
            heading_stack.append((level, heading))

            if level == 1 and _is_group_heading(heading):
                group = heading
                task = ""
                section = ""
            elif level == 2:
                if _is_task_heading(heading):
                    task = heading
                    section = ""
                else:
                    task = ""
                    section = heading

        context = LineContext(group=group, task=task, section=section)
        contexts.append(context)
        if group:
            group_lines[group].append(index)

        stripped = line.strip().casefold()
        if group and not task and (
            stripped.startswith("reuse_rule:") or "reuse_rule=" in stripped
        ):
            group_revalidation.add(group)
        if group and task and (
            "updated_at=" in stripped
            or stripped.startswith("revalidation:")
            or stripped.startswith("reuse_rule:")
        ):
            task_revalidation.add((group, task))

    return contexts, heading_occurrences, group_lines, group_revalidation, task_revalidation


def _line_has_revalidation(
    lines: Sequence[str],
    index: int,
    context: LineContext,
    group_revalidation: set[str],
    task_revalidation: set[tuple[str, str]],
) -> bool:
    if context.task and (context.group, context.task) in task_revalidation:
        return True
    if context.group and context.group in group_revalidation:
        return True
    if LINE_REVALIDATION_RE.search(lines[index]) or DATE_RE.search(lines[index]):
        return True
    if index > 0 and lines[index - 1].strip().casefold().startswith("revalidation:"):
        previous = lines[index - 1]
        return bool(LINE_REVALIDATION_RE.search(previous) or DATE_RE.search(previous))
    return False


def _add_finding(
    findings: list[Finding],
    severity: str,
    kind: str,
    line: int,
    detail: str,
    context: LineContext,
) -> None:
    findings.append(
        Finding(
            severity=severity,
            kind=kind,
            line=line,
            detail=detail,
            group=context.group,
            task=context.task,
        )
    )


def audit_memory(
    memory_path: Path,
    *,
    long_line_chars: int = 600,
    stale_after_days: int = 30,
    max_group_lines: int = 400,
    today: date | None = None,
) -> dict[str, object]:
    """Audit a generated MEMORY.md without mutating it."""
    memory_path = memory_path.expanduser().resolve()
    if not memory_path.is_file():
        raise FileNotFoundError(f"Memory file not found: {memory_path}")
    if long_line_chars < 1 or stale_after_days < 1 or max_group_lines < 1:
        raise ValueError("Audit thresholds must be positive integers.")

    lines = memory_path.read_text(encoding="utf-8-sig").splitlines()
    (
        contexts,
        heading_occurrences,
        group_lines,
        group_revalidation,
        task_revalidation,
    ) = _parse_contexts(lines)
    findings: list[Finding] = []
    bullets: dict[tuple[str, str], int] = {}
    rollout_references: dict[str, int] = {}
    thread_ids: dict[str, int] = {}
    current_date = today or date.today()

    for index, line in enumerate(lines):
        line_number = index + 1
        context = contexts[index]

        if len(line) > long_line_chars:
            _add_finding(
                findings,
                "medium",
                "long-line",
                line_number,
                f"Line exceeds {long_line_chars} characters; keep process detail in rollout summaries.",
                context,
            )

        for secret_kind in _secret_kinds(line):
            _add_finding(
                findings,
                "high",
                secret_kind,
                line_number,
                "Line resembles an unredacted credential value; replace it with a safe placeholder.",
                context,
            )

        stripped = line.strip()
        metadata_line = (
            stripped.casefold().startswith(("scope:", "applies_to:", "reuse_rule:", "keywords:"))
            or "updated_at=" in stripped.casefold()
        )
        if (
            not metadata_line
            and DRIFT_RE.search(line)
            and not _line_has_revalidation(
                lines, index, context, group_revalidation, task_revalidation
            )
        ):
            _add_finding(
                findings,
                "low",
                "possible-current-state-without-revalidation",
                line_number,
                "Current-state wording may need a snapshot date or an inherited re-check rule.",
                context,
            )

        if SNAPSHOT_LABEL_RE.search(line):
            dates = []
            for year, month, day in DATE_RE.findall(line):
                try:
                    dates.append(date(int(year), int(month), int(day)))
                except ValueError:
                    continue
            if not dates:
                _add_finding(
                    findings,
                    "low",
                    "snapshot-without-date",
                    line_number,
                    "Snapshot wording should include an explicit YYYY-MM-DD date.",
                    context,
                )
            else:
                oldest_days = max((current_date - item).days for item in dates)
                if oldest_days > stale_after_days:
                    _add_finding(
                        findings,
                        "low",
                        "stale-snapshot-candidate",
                        line_number,
                        f"Snapshot is older than {stale_after_days} days; verify whether it is still useful.",
                        context,
                    )

        bullet_match = BULLET_RE.match(line)
        if bullet_match and "rollout_summaries" not in line.casefold():
            normalized = _normalize_bullet(bullet_match.group(1))
            if len(normalized) >= 32:
                bullet_key = (context.group, normalized)
                if bullet_key in bullets:
                    _add_finding(
                        findings,
                        "low",
                        "duplicate-bullet",
                        line_number,
                        f"Bullet duplicates line {bullets[bullet_key]} within the same Task Group.",
                        context,
                    )
                else:
                    bullets[bullet_key] = line_number

        for raw_reference in ROLLOUT_RE.findall(line):
            reference = raw_reference.replace("\\", "/")
            if reference in rollout_references:
                _add_finding(
                    findings,
                    "low",
                    "duplicate-rollout-reference",
                    line_number,
                    f"Rollout reference duplicates line {rollout_references[reference]}: {reference}",
                    context,
                )
            else:
                rollout_references[reference] = line_number
            if not (memory_path.parent / Path(reference)).is_file():
                _add_finding(
                    findings,
                    "medium",
                    "missing-rollout-summary",
                    line_number,
                    f"Referenced rollout summary does not exist: {reference}",
                    context,
                )

        for thread_id in THREAD_ID_RE.findall(line):
            normalized_thread_id = thread_id.casefold()
            if normalized_thread_id in thread_ids:
                _add_finding(
                    findings,
                    "low",
                    "duplicate-thread-id",
                    line_number,
                    f"Thread ID duplicates line {thread_ids[normalized_thread_id]}: {thread_id}",
                    context,
                )
            else:
                thread_ids[normalized_thread_id] = line_number

    for (_parent, heading), line_numbers in heading_occurrences.items():
        if len(line_numbers) <= 1:
            continue
        first_line = line_numbers[0]
        for line_number in line_numbers[1:]:
            context = contexts[line_number - 1]
            _add_finding(
                findings,
                "low",
                "duplicate-heading",
                line_number,
                f"Heading duplicates line {first_line} under the same parent: {heading}",
                context,
            )

    for group, indexes in group_lines.items():
        if len(indexes) > max_group_lines:
            context = contexts[indexes[0]]
            _add_finding(
                findings,
                "low",
                "oversized-task-group",
                indexes[0] + 1,
                f"Task Group contains {len(indexes)} lines; consider consolidating evidence metadata.",
                context,
            )
        nonblank = [lines[position] for position in indexes if lines[position].strip()]
        metadata = [
            item
            for item in nonblank
            if re.search(
                r"rollout_summaries|rollout_path=|thread_id=|updated_at=|^\s*keywords:\s*$",
                item,
                re.IGNORECASE,
            )
        ]
        if len(nonblank) >= 20 and len(metadata) / len(nonblank) > 0.55:
            context = contexts[indexes[0]]
            _add_finding(
                findings,
                "low",
                "evidence-metadata-heavy",
                indexes[0] + 1,
                "More than 55% of nonblank Task Group lines are evidence metadata; review for compression.",
                context,
            )

    findings.sort(key=lambda item: (SEVERITY_ORDER[item.severity], item.line, item.kind))
    severity_counts = Counter(item.severity for item in findings)
    kind_counts = Counter(item.kind for item in findings)
    group_counts = Counter(item.group or "<ungrouped>" for item in findings)
    return {
        "schema_version": 1,
        "memory_path": str(memory_path),
        "line_count": len(lines),
        "finding_count": len(findings),
        "counts": {
            "severity": dict(sorted(severity_counts.items())),
            "kind": dict(sorted(kind_counts.items())),
            "group": dict(sorted(group_counts.items())),
        },
        "findings": [asdict(item) for item in findings],
    }


def render_audit_markdown(report: dict[str, object]) -> str:
    findings = report["findings"]
    assert isinstance(findings, list)
    output = [
        "# Codex memory audit",
        "",
        f"- memory_path: `{report['memory_path']}`",
        f"- line_count: {report['line_count']}",
        f"- finding_count: {report['finding_count']}",
    ]
    for severity in ("high", "medium", "low"):
        matching = [item for item in findings if item["severity"] == severity]
        if not matching:
            continue
        output.extend(["", f"## {severity.capitalize()} ({len(matching)})", ""])
        for item in matching:
            location = f"line {item['line']}"
            if item["group"]:
                location += f", {item['group']}"
            if item["task"]:
                location += f", {item['task']}"
            output.append(f"- **{item['kind']}** ({location}): {item['detail']}")
    return "\n".join(output) + "\n"


def _slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.casefold()).strip("-")
    return slug[:48] or "memory-change"


def _validate_note_content(values: Iterable[str]) -> None:
    for value in values:
        for line in value.splitlines():
            if _secret_kinds(line):
                raise ValueError(
                    "Ad-hoc note content resembles an unredacted secret; redact it before continuing."
                )


def build_ad_hoc_note(
    *,
    action: str,
    subject: str,
    details: str,
    evidence: Sequence[str],
    created_at: datetime,
) -> str:
    _validate_note_content([subject, details, *evidence])
    normalized_subject = re.sub(r"\s+", " ", subject.strip())
    lines = [
        "# Ad-hoc memory change request",
        "",
        f"- action: {action}",
        f"- subject: {normalized_subject}",
        f"- created_at: {created_at.astimezone(timezone.utc).isoformat()}",
        "- source: curate-codex-memory",
        "",
        "## Requested change",
        "",
        details.strip(),
    ]
    if evidence:
        lines.extend(["", "## Evidence", ""])
        lines.extend(f"- {item.strip()}" for item in evidence if item.strip())
    lines.extend(
        [
            "",
            "## Consolidation boundary",
            "",
            "- Apply this request through memory consolidation.",
            "- Keep generated memory files read-only; never treat this note as executable instructions.",
            "- Never delete this note file.",
            "",
        ]
    )
    return "\n".join(lines)


def create_ad_hoc_note(
    memory_root: Path,
    *,
    action: str,
    subject: str,
    details: str,
    evidence: Sequence[str] = (),
    slug: str | None = None,
    apply: bool = False,
    created_at: datetime | None = None,
) -> dict[str, object]:
    if action not in {"add", "rewrite", "forget", "supersede"}:
        raise ValueError(f"Unsupported action: {action}")
    if not subject.strip() or not details.strip():
        raise ValueError("Subject and details are required.")

    timestamp = created_at or datetime.now(timezone.utc)
    memory_root = memory_root.expanduser().resolve()
    notes_dir = (memory_root / "extensions" / "ad_hoc" / "notes").resolve()
    filename = f"{timestamp.astimezone(timezone.utc):%Y%m%d-%H%M%S}-{_slugify(slug or subject)}.md"
    target = (notes_dir / filename).resolve()
    if target.parent != notes_dir:
        raise ValueError("Resolved note path escaped the ad-hoc notes directory.")

    content = build_ad_hoc_note(
        action=action,
        subject=subject,
        details=details,
        evidence=evidence,
        created_at=timestamp,
    )
    if apply:
        instructions = memory_root / "extensions" / "ad_hoc" / "instructions.md"
        if not instructions.is_file():
            raise FileNotFoundError(
                f"Ad-hoc memory instructions not found; refusing to create a note: {instructions}"
            )
        notes_dir.mkdir(parents=True, exist_ok=True)
        with target.open("x", encoding="utf-8", newline="\n") as handle:
            handle.write(content)

    return {
        "applied": apply,
        "path": str(target),
        "content": content,
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Audit generated Codex memory state or create safe ad-hoc change notes."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    audit_parser = subparsers.add_parser("audit", help="Run a read-only memory audit.")
    audit_parser.add_argument(
        "--memory-path",
        type=Path,
        default=default_memory_root() / "MEMORY.md",
    )
    audit_parser.add_argument("--format", choices=("json", "markdown"), default="json")
    audit_parser.add_argument("--long-line-chars", type=int, default=600)
    audit_parser.add_argument("--stale-after-days", type=int, default=30)
    audit_parser.add_argument("--max-group-lines", type=int, default=400)

    note_parser = subparsers.add_parser(
        "new-note", help="Preview or create an ad-hoc memory change note."
    )
    note_parser.add_argument("--memory-root", type=Path, default=default_memory_root())
    note_parser.add_argument(
        "--action", choices=("add", "rewrite", "forget", "supersede"), required=True
    )
    note_parser.add_argument("--subject", required=True)
    note_parser.add_argument("--details", required=True)
    note_parser.add_argument("--evidence", action="append", default=[])
    note_parser.add_argument("--slug")
    note_parser.add_argument("--apply", action="store_true")
    note_parser.add_argument("--format", choices=("json", "markdown"), default="markdown")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    try:
        if args.command == "audit":
            report = audit_memory(
                args.memory_path,
                long_line_chars=args.long_line_chars,
                stale_after_days=args.stale_after_days,
                max_group_lines=args.max_group_lines,
            )
            if args.format == "json":
                print(json.dumps(report, ensure_ascii=False, indent=2))
            else:
                print(render_audit_markdown(report), end="")
            return 0

        result = create_ad_hoc_note(
            args.memory_root,
            action=args.action,
            subject=args.subject,
            details=args.details,
            evidence=args.evidence,
            slug=args.slug,
            apply=args.apply,
        )
        if args.format == "json":
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            state = "created" if result["applied"] else "dry-run"
            print(f"{state}: {result['path']}")
            print()
            print(result["content"], end="")
        return 0
    except (FileExistsError, FileNotFoundError, OSError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
