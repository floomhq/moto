#!/usr/bin/env python3
"""
Gemini independent audit hook for Claude Code Stop events.
Sends assistant output + user request + CLAUDE.md + workplan + git diff to Gemini.
If score < 10/10, feeds back issues to Claude to keep working.

Opt-in: touch ~/.claude/.gemini-audit-enabled
Opt-out: rm ~/.claude/.gemini-audit-enabled
Skip: only trivial responses (<50 chars).

Requires:
  - GEMINI_API_KEY or GOOGLE_API_KEY env var
  - pip install google-genai
"""

import collections
import fcntl
import glob
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
FLAG_FILE = os.path.expanduser("~/.claude/.gemini-audit-enabled")
LOG_FILE = os.path.expanduser("~/.claude/hooks/gemini-audit.log")
THRESHOLD = 10  # Minimum score to pass

LOG_MAX_BYTES = 1_000_000  # 1 MB
LOG_BACKUP_COUNT = 1


def rotate_log():
    """Rotate log file if it exceeds LOG_MAX_BYTES. Keep LOG_BACKUP_COUNT backups."""
    log_path = Path(LOG_FILE)
    if not log_path.exists():
        return
    try:
        if log_path.stat().st_size > LOG_MAX_BYTES:
            for i in range(LOG_BACKUP_COUNT, 0, -1):
                src = log_path.with_suffix(f".log.{i}")
                dst = log_path.with_suffix(f".log.{i + 1}")
                if src.exists():
                    if i >= LOG_BACKUP_COUNT:
                        src.unlink()
                    else:
                        shutil.move(str(src), str(dst))
            shutil.move(str(log_path), str(log_path.with_suffix(".log.1")))
    except Exception:
        pass


def log(msg):
    try:
        with open(LOG_FILE, "a") as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            try:
                f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} {msg}\n")
            finally:
                fcntl.flock(f, fcntl.LOCK_UN)
    except Exception:
        pass


def get_git_diff():
    """Get staged + unstaged changes from git diff."""
    stat_parts = []
    diff_parts = []
    cwd = os.getcwd()

    # Staged changes
    try:
        stat_r = subprocess.run(
            ["git", "diff", "--cached", "--stat", "--no-color"],
            capture_output=True, text=True, timeout=5, cwd=cwd,
        )
        diff_r = subprocess.run(
            ["git", "diff", "--cached", "--no-color"],
            capture_output=True, text=True, timeout=5, cwd=cwd,
        )
        if stat_r.returncode == 0 and stat_r.stdout.strip():
            stat_parts.append("STAGED:\n" + stat_r.stdout.strip())
        if diff_r.returncode == 0 and diff_r.stdout.strip():
            diff_parts.append(diff_r.stdout.strip())
    except Exception:
        pass

    # Unstaged changes
    try:
        stat_r = subprocess.run(
            ["git", "diff", "--stat", "--no-color"],
            capture_output=True, text=True, timeout=5, cwd=cwd,
        )
        diff_r = subprocess.run(
            ["git", "diff", "--no-color"],
            capture_output=True, text=True, timeout=5, cwd=cwd,
        )
        if stat_r.returncode == 0 and stat_r.stdout.strip():
            stat_parts.append("UNSTAGED:\n" + stat_r.stdout.strip())
        if diff_r.returncode == 0 and diff_r.stdout.strip():
            diff_parts.append(diff_r.stdout.strip())
    except Exception:
        pass

    return "\n".join(stat_parts), "\n".join(diff_parts)


def get_context(data):
    """Extract task context from transcript, CLAUDE.md, and workplans."""
    cwd = data.get("cwd", os.getcwd())
    context_parts = []

    # 1. Extract user messages, tool activity, and tool results from transcript
    transcript_path = data.get("transcript_path", "")
    user_messages = []
    assistant_activity = []  # Recent tool calls and text blocks for evidence
    # Track pending tool calls to pair with results
    pending_tools = {}  # tool_use_id -> activity_index
    if transcript_path and os.path.exists(transcript_path):
        try:
            with open(transcript_path) as f:
                tail = collections.deque(f, maxlen=200)
            for raw_line in tail:
                raw_line = raw_line.strip()
                if not raw_line:
                    continue
                try:
                    entry = json.loads(raw_line)
                    entry_type = entry.get("type", "")
                    msg = entry.get("message", {}) if isinstance(entry.get("message"), dict) else {}
                    content = msg.get("content", "")

                    if entry_type == "user":
                        if isinstance(content, list):
                            # Check for tool_result blocks (command output evidence)
                            has_tool_results = False
                            for block in content:
                                if isinstance(block, dict) and block.get("type") == "tool_result":
                                    has_tool_results = True
                                    result_text = block.get("content", "")
                                    tool_id = block.get("tool_use_id", "")
                                    is_error = block.get("is_error", False)
                                    if result_text and len(str(result_text)) > 5:
                                        result_str = str(result_text)[:500]
                                        prefix = "ERROR" if is_error else "OUTPUT"
                                        # Append result to the matching tool call if found
                                        if tool_id in pending_tools:
                                            idx = pending_tools[tool_id]
                                            assistant_activity[idx] += f"\n  -> {prefix}: {result_str}"
                                        else:
                                            assistant_activity.append(f"[{prefix}] {result_str}")
                            if has_tool_results:
                                continue  # Don't treat as user message
                            # Normal user message with text blocks
                            text_parts = []
                            for block in content:
                                if isinstance(block, dict) and block.get("type") == "text":
                                    text_parts.append(block.get("text", ""))
                            content = "\n".join(text_parts)
                        if isinstance(content, str) and len(content) > 10:
                            # Skip hook feedback messages (they pollute context)
                            if "Gemini Independent Audit:" in content or "Fix the issues listed above" in content:
                                continue
                            if "Stop hook" in content and "BELOW THRESHOLD" in content:
                                continue
                            user_messages.append(content[:1000])

                    elif entry_type == "assistant" and isinstance(content, list):
                        for block in content:
                            if not isinstance(block, dict):
                                continue
                            btype = block.get("type", "")
                            if btype == "tool_use":
                                name = block.get("name", "?")
                                tool_id = block.get("id", "")
                                inp = block.get("input", {})
                                summary = ""
                                if "command" in inp:
                                    summary = f"$ {inp['command'][:200]}"
                                elif "file_path" in inp:
                                    summary = inp["file_path"]
                                elif "pattern" in inp:
                                    summary = f"pattern={inp['pattern']}"
                                activity_line = f"[{name}] {summary}"[:300]
                                assistant_activity.append(activity_line)
                                if tool_id:
                                    pending_tools[tool_id] = len(assistant_activity) - 1
                            # Skip [text] blocks - they're old assistant responses
                            # that create stale context. Gemini already sees the
                            # current response via last_assistant_message.
                except (json.JSONDecodeError, KeyError):
                    continue
        except Exception:
            pass

    # User messages are PRIMARY context (they define what Claude was asked)
    if user_messages:
        recent = user_messages[-3:]
        msgs = "\n---\n".join(recent)
        context_parts.append(f"USER'S REQUEST (last {len(recent)} messages - THIS defines the task):\n{msgs}")

    # Recent assistant activity shows what tools were called (evidence of work done)
    if assistant_activity:
        recent_activity = assistant_activity[-30:]  # Last 30 actions
        activity_text = "\n".join(recent_activity)
        context_parts.append(f"RECENT AGENT ACTIVITY (tools called, commands run - this is evidence of work done):\n{activity_text}")

    # 2. Read CLAUDE.md from project root (quality standards, not task definition)
    claude_md = Path(cwd) / "CLAUDE.md"
    if claude_md.exists():
        try:
            text = claude_md.read_text()
            context_parts.append(f"PROJECT CLAUDE.MD (quality standards):\n{text}")
        except Exception:
            pass

    # 3. Only include workplan if recently modified (within last 2 hours)
    workplans = sorted(glob.glob(str(Path(cwd) / "WORKPLAN-*.md")), reverse=True)
    if workplans:
        try:
            wp_path = Path(workplans[0])
            age_hours = (time.time() - wp_path.stat().st_mtime) / 3600
            if age_hours < 2:
                text = wp_path.read_text()
                context_parts.append(f"ACTIVE WORKPLAN ({wp_path.name}, modified {age_hours:.1f}h ago):\n{text}")
            else:
                log(f"SKIP stale workplan: {wp_path.name} ({age_hours:.0f}h old)")
        except Exception:
            pass

    return "\n\n".join(context_parts) if context_parts else ""


def audit_with_gemini(assistant_text, diff_stat, diff_text, task_context):
    """Send to Gemini for independent scoring."""
    from google import genai
    from google.genai import types

    BUDGET_ASSISTANT = 200_000
    BUDGET_CONTEXT = 50_000
    BUDGET_DIFF = 50_000

    diff_section = ""
    if diff_stat:
        diff_section = f"""
CODE CHANGES (git diff --stat):
{diff_stat[:5000]}

CODE CHANGES (diff):
{diff_text[:BUDGET_DIFF]}
"""
    else:
        diff_section = "\n(No code diff available - changes may already be committed. Score based on the agent's response quality, completeness, and whether claims seem credible.)\n"

    context_section = ""
    if task_context:
        context_section = f"""
TASK CONTEXT (user requests, agent activity log, project rules, active workplan):
{task_context[:BUDGET_CONTEXT]}
"""

    prompt = f"""You are an independent reviewer auditing an AI agent's output.
Score the output 1-10 and list specific issues. Be harsh but fair.

FIRST: Determine the TASK TYPE from the user's request:
- CODING: writing/editing code, fixing bugs, configuration, deployment
- ADVISORY: answering questions, giving advice, strategy, negotiation, legal guidance, analysis, research, explanations

SCORING CRITERIA FOR CODING TASKS:
- 10/10: Code changes verified working (tests pass, builds succeed), every claim backed by evidence
- 8-9/10: Good work but has gaps (untested changes, unverified claims)
- 6-7/10: Notable problems (incomplete, missing verification)
- 1-5/10: Broken, wrong, or fabricated

SCORING CRITERIA FOR ADVISORY TASKS:
- 10/10: Accurate, complete, actionable advice that fully addresses the user's question. Covers all angles the user asked about. No factual errors.
- 8-9/10: Good advice but misses an important angle or has minor gaps
- 6-7/10: Partially addresses the question, vague, or missing key considerations
- 1-5/10: Wrong, misleading, or unhelpful

FOR ADVISORY TASKS: Do NOT demand command output, code verification, or test results. The agent is giving advice, not writing code. Score based on the quality, accuracy, completeness, and actionability of the advice itself. An advisory response with no code changes and no command output can absolutely score 10/10 if the advice is thorough and correct.

IMPORTANT RULES:
- The agent handles many task types: coding, research, configuration, answering questions, debugging, negotiation, strategy.
- The git diff may be UNRELATED to the current response. Do NOT penalize for diff/response mismatch unless the agent explicitly claims to have made specific code changes that aren't in the diff.
- Score the response on its OWN merits: accuracy, completeness, helpfulness, specificity.
- Only use the diff to verify if the agent explicitly claims "I changed X" or "I fixed Y".
- When the agent shows verified command output (e.g., curl responses, file contents, test results), treat those as evidence.
- SELF-SCORING IS EXPECTED: The agent is instructed to self-score work. This is the standard workflow. Do NOT penalize for self-assessments. YOUR job is to independently verify whether the self-score is accurate.
- TOOL OUTPUT IS EVIDENCE: When the agent shows tool results (command output, file reads, curl responses, grep results), these are real executed commands with real output. Treat them as verified evidence.
- AGENT ACTIVITY LOG: The RECENT AGENT ACTIVITY section in the context shows actual tool calls and commands the agent executed during this session. This is objective evidence of work done, not claims by the agent. Use it to verify the agent's claims.
- Use the TASK CONTEXT below to understand what the agent was asked to do. The USER'S REQUEST section defines the task. Score whether the agent completed THAT request.
{context_section}
WHAT THE AGENT SAID:
{assistant_text[:BUDGET_ASSISTANT]}
{diff_section}
RESPOND IN EXACTLY THIS FORMAT (no markdown, no extra text):
SCORE: X/10
ISSUES:
- issue 1
- issue 2
- issue 3
VERDICT: PASS or FAIL
"""

    client = genai.Client(api_key=GEMINI_API_KEY)
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config=types.GenerateContentConfig(
            max_output_tokens=1024,
            temperature=0.0,
        ),
    )
    return response.text


def main():
    rotate_log()

    # Check opt-in flag
    if not os.path.exists(FLAG_FILE):
        sys.exit(0)

    # Fail-open if no API key
    if not GEMINI_API_KEY:
        log("SKIP: no GEMINI_API_KEY or GOOGLE_API_KEY set")
        sys.exit(0)

    # Read hook input from stdin
    try:
        raw = sys.stdin.read()
        data = json.loads(raw)
    except (json.JSONDecodeError, Exception):
        log("ERROR: could not parse stdin")
        sys.exit(0)

    log(f"FIELDS: {list(data.keys())}")

    # Always re-audit, even after a previous block. Claude must keep working
    # until Gemini scores 10/10. The stop_hook_active flag is ignored so that
    # every stop attempt is independently verified.
    if data.get("stop_hook_active"):
        log("RE-AUDIT: stop_hook_active=true, auditing again")

    # Extract assistant's message
    assistant_text = data.get("last_assistant_message", "")
    if not assistant_text:
        tool_input = data.get("tool_input", {})
        if isinstance(tool_input, dict):
            assistant_text = tool_input.get("result", "")
        if not assistant_text:
            assistant_text = data.get("result", data.get("message", ""))
    if isinstance(assistant_text, list):
        parts = []
        for block in assistant_text:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(block.get("text", ""))
        assistant_text = "\n".join(parts)

    # Skip trivial responses
    if len(str(assistant_text)) < 50:
        log(f"SKIP: trivial response ({len(str(assistant_text))} chars)")
        sys.exit(0)

    # Skip system/error messages that Claude can't fix (prevents infinite loops)
    SKIP_PATTERNS = [
        "You're out of extra usage",
        "You've hit the rate limit",
        "rate limit",
        "context window full",
        "connection error",
        "network error",
        "API error",
        "internal server error",
        "service unavailable",
    ]
    assistant_lower = str(assistant_text).lower()
    for pattern in SKIP_PATTERNS:
        if pattern.lower() in assistant_lower:
            log(f"SKIP: system/error message detected ('{pattern}')")
            sys.exit(0)

    # Gather context: user request, CLAUDE.md, workplan
    task_context = get_context(data)
    log(f"CONTEXT: {len(task_context)} chars")

    # Check for code changes
    diff_stat, diff_text = get_git_diff()

    # Run Gemini audit
    try:
        log("AUDIT: sending to Gemini...")
        start = time.time()
        result = audit_with_gemini(str(assistant_text), diff_stat, diff_text, task_context)
        elapsed = time.time() - start
        log(f"AUDIT: Gemini responded in {elapsed:.1f}s")
    except Exception as e:
        log(f"ERROR: Gemini call failed: {e}")
        sys.exit(0)  # Don't block on API errors

    # Parse score
    score = None
    for line in result.split("\n"):
        line = line.strip()
        if line.startswith("SCORE:"):
            try:
                score_str = line.split(":")[1].strip().split("/")[0].strip()
                score = int(score_str)
            except (ValueError, IndexError):
                pass
            break

    if score is None:
        log(f"WARN: could not parse score from: {result[:500]}")
        sys.exit(0)

    log(f"SCORE: {score}/10")

    if score >= THRESHOLD:
        log(f"PASS: {score}/10 >= {THRESHOLD}")
        print(json.dumps({"decision": "approve"}))
        sys.exit(0)
    else:
        log(f"FAIL: {score}/10 < {THRESHOLD}")
        reason = f"[Gemini Independent Audit: {score}/10 - BELOW THRESHOLD]\n\n{result}\n\nFix the issues listed above before returning."
        print(json.dumps({"decision": "block", "reason": reason}))
        sys.exit(2)


if __name__ == "__main__":
    main()
