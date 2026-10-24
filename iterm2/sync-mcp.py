"""Mirror Claude Code MCP servers (user + per-project) from one .claude.json into another.

Usage: sync-mcp.py <source .claude.json> <target .claude.json>
Only mcpServers keys are touched; account and other state in the target are left alone.
"""
import json, os, sys

src_path, dst_path = sys.argv[1], sys.argv[2]
src = json.load(open(src_path))
try:
    dst = json.load(open(dst_path))
except FileNotFoundError:
    dst = {}
before = json.dumps(dst, sort_keys=True)

dst["mcpServers"] = src.get("mcpServers", {})
src_projects = src.get("projects", {})
dst_projects = dst.setdefault("projects", {})
for path in set(src_projects) | set(dst_projects):
    servers = (src_projects.get(path) or {}).get("mcpServers") or {}
    if servers:
        dst_projects.setdefault(path, {})["mcpServers"] = servers
    elif path in dst_projects and dst_projects[path].get("mcpServers"):
        dst_projects[path]["mcpServers"] = {}

if json.dumps(dst, sort_keys=True) != before:
    tmp = dst_path + ".mcp-sync.tmp"
    with open(tmp, "w") as f:
        json.dump(dst, f, indent=2)
    os.chmod(tmp, 0o600)
    os.replace(tmp, dst_path)
