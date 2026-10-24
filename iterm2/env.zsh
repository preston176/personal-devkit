# Per-iTerm-profile CLI isolation. Sourced from ~/.zshenv when CLI_PROFILE is set.
# "work" uses the normal home-directory config; other profiles get their own dirs.
export CLI_PROFILE
case "$CLI_PROFILE" in
  work) ;;
  *)
    export CLI_PROFILE_DIR="$HOME/.cli-profiles/$CLI_PROFILE"
    if [[ -d $CLI_PROFILE_DIR ]]; then
      export CLAUDE_CONFIG_DIR="$CLI_PROFILE_DIR/claude"
      export CODEX_HOME="$CLI_PROFILE_DIR/codex"
      export GH_CONFIG_DIR="$CLI_PROFILE_DIR/gh"
      export GIT_CONFIG_GLOBAL="$CLI_PROFILE_DIR/gitconfig"
      export CLOUDSDK_CONFIG="$CLI_PROFILE_DIR/gcloud"
      export NPM_CONFIG_USERCONFIG="$CLI_PROFILE_DIR/npmrc"
      export XDG_CONFIG_HOME="$CLI_PROFILE_DIR/config"
      export XDG_DATA_HOME="$CLI_PROFILE_DIR/data"
      export XDG_STATE_HOME="$CLI_PROFILE_DIR/state"
      export XDG_CACHE_HOME="$CLI_PROFILE_DIR/cache"
      vercel() { command vercel --global-config "$CLI_PROFILE_DIR/vercel" "$@"; }
      vc() { vercel "$@"; }
      # MCP servers are shared with the "work" profile (~/.claude.json is the source of truth).
      # `claude mcp ...` edits the shared list; every other launch syncs it in first.
      claude() {
        if [[ $1 == mcp ]]; then
          (unset CLAUDE_CONFIG_DIR; command claude "$@")
        else
          /usr/bin/python3 -I "$HOME/.cli-profiles/sync-mcp.py" "$HOME/.claude.json" "$CLAUDE_CONFIG_DIR/.claude.json"
          command claude "$@"
        fi
      }
    else
      print -u2 "cli-profiles: unknown profile '$CLI_PROFILE', using default config"
      unset CLI_PROFILE_DIR
    fi
    ;;
esac
