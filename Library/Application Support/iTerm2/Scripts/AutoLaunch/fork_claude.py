#!/usr/bin/env python3
import iterm2
import json
import os
import glob
import subprocess


HOME_DIR = os.path.expanduser("~")
DEFAULT_CONFIG_DIR = os.path.join(HOME_DIR, ".claude")
SESSIONS_DIRS = [
    os.path.join(d, "sessions")
    for d in glob.glob(os.path.join(HOME_DIR, ".claude*"))
    if os.path.isdir(os.path.join(d, "sessions"))
]


def find_claude_session(shell_pid):
    """Find Claude session ID and config dir by walking descendant PIDs of the shell.

    Returns (session_id, config_dir) or (None, None).
    """
    descendants = set()
    queue = [str(shell_pid)]
    while queue:
        ppid = queue.pop()
        result = subprocess.run(
            ["pgrep", "-P", ppid], capture_output=True, text=True
        )
        for pid in result.stdout.strip().split("\n"):
            if pid and pid not in descendants:
                descendants.add(pid)
                queue.append(pid)

    for sessions_dir in SESSIONS_DIRS:
        for path in glob.glob(os.path.join(sessions_dir, "*.json")):
            pid_str = os.path.basename(path).removesuffix(".json")
            if pid_str in descendants:
                with open(path) as f:
                    data = json.load(f)
                    # config dir is the parent of the sessions/ dir
                    config_dir = os.path.dirname(sessions_dir)
                    return data.get("sessionId"), config_dir
    return None, None


async def main(connection):
    @iterm2.RPC
    async def fork_claude(session_id):
        app = await iterm2.async_get_app(connection)
        session = app.get_session_by_id(session_id)
        if not session:
            return

        # Resolve session ID and config dir from Claude's PID-based state files
        shell_pid = await session.async_get_variable("pid")
        claude_session_id, config_dir = find_claude_session(shell_pid) if shell_pid else (None, None)

        env_prefix = ""
        if config_dir and config_dir != DEFAULT_CONFIG_DIR:
            env_prefix = f"CLAUDE_CONFIG_DIR={config_dir} "

        if claude_session_id:
            cmd = f"{env_prefix}claude --resume {claude_session_id} --fork-session"
        else:
            # Fallback: iTerm2 user variable set by cc() wrapper
            name = await session.async_get_variable("user.claude_session")
            if name:
                cmd = f"{env_prefix}claude --resume {name} --fork-session"
            else:
                cmd = f"{env_prefix}claude --continue --fork-session"

        new_session = await session.async_split_pane(vertical=True)
        await new_session.async_send_text(cmd + "\n")

    await fork_claude.async_register(connection)


iterm2.run_forever(main)
