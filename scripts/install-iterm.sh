#!/usr/bin/env bash
#
# Set up the three iTerm2 profiles with isolated CLI logins.
#
#   work            the normal home-directory config (~/.claude, ~/.config/gh, ...)
#   work - preston  isolated logins; shares Claude chat history with "work"
#   personal        isolated logins; own Claude chat history
#
# Each isolated profile keeps Claude Code, Codex, gh, git, gcloud, Vercel,
# npm and XDG config under ~/.cli-profiles/<slug>/. All three share CLAUDE.md,
# rules, skills, settings, plugins and MCP servers with ~/.claude.
#
# Usage: ./scripts/install-iterm.sh [--dry-run]
# Re-running is idempotent. Anything real that sits where a shared link should
# go is moved aside to <name>.pre-devkit, never deleted.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ITERM_SRC="$REPO_ROOT/iterm2"
PROFILES_HOME="$HOME/.cli-profiles"
DYNAMIC_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

# Isolated profiles (the "work" profile needs no directory of its own)
ISOLATED_PROFILES=(work-preston personal)
# Isolated profiles that also share Claude chat history with "work"
SHARE_HISTORY=(work-preston)

# Linked into every isolated profile's Claude config dir
CLAUDE_SHARED=(CLAUDE.md rules skills settings.json settings.local.json plugins)
# Linked only into the SHARE_HISTORY profiles
CLAUDE_HISTORY=(projects history.jsonl file-history paste-cache)
# Non-credential ~/.config entries reused by every profile
XDG_SHARED=(btop cmux iterm2 raycast)

DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ iTerm2 profiles are macOS only (got $OSTYPE)"
  exit 1
fi
[ -d /Applications/iTerm.app ] || echo "⚠️  iTerm2 not found in /Applications; profiles will load once it's installed"

run() {
  if $DRY_RUN; then echo "  [dry-run] $*"; else "$@"; fi
}

# Point $2 at $1, moving any real file or folder already at $2 out of the way.
link() {
  local target="$1" path="$2"
  if [ -L "$path" ] && [ "$(readlink "$path")" == "$target" ]; then
    return
  fi
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    run mv "$path" "$path.pre-devkit"
    echo "  moved existing $path to $path.pre-devkit"
  fi
  run ln -sfn "$target" "$path"
  echo "  linked $path -> $target"
}

contains() {
  local item="$1"; shift
  for x in "$@"; do [[ "$x" == "$item" ]] && return 0; done
  return 1
}

$DRY_RUN && echo "🔍 Dry run: nothing will be changed"
echo "🖥️  Setting up iTerm2 CLI profiles..."

# ---------- 1. Shared scripts ----------

run mkdir -p "$PROFILES_HOME"
run cp "$ITERM_SRC/env.zsh" "$PROFILES_HOME/env.zsh"
run cp "$ITERM_SRC/sync-mcp.py" "$PROFILES_HOME/sync-mcp.py"
echo "✅ env.zsh and sync-mcp.py installed to $PROFILES_HOME"

# Shared targets must exist, or the links dangle and Claude can't write through them
for d in rules skills plugins projects file-history paste-cache; do
  [ -d "$HOME/.claude/$d" ] || run mkdir -p "$HOME/.claude/$d"
done
for f in settings.json settings.local.json; do
  [ -f "$HOME/.claude/$f" ] || { $DRY_RUN || echo '{}' > "$HOME/.claude/$f"; echo "  created ~/.claude/$f"; }
done
for f in CLAUDE.md history.jsonl; do
  [ -f "$HOME/.claude/$f" ] || run touch "$HOME/.claude/$f"
done

# ---------- 2. Per-profile directories ----------

for slug in "${ISOLATED_PROFILES[@]}"; do
  P="$PROFILES_HOME/$slug"
  echo "📁 $slug"
  run mkdir -p "$P"/{claude,codex,gh,gcloud,vercel,config,data,state,cache}

  for d in "${XDG_SHARED[@]}"; do
    [ -e "$HOME/.config/$d" ] && link "$HOME/.config/$d" "$P/config/$d"
  done

  # Codex: keep login and MCP OAuth tokens in the profile dir, not the shared keychain
  if [ ! -f "$P/codex/config.toml" ]; then
    $DRY_RUN || printf 'cli_auth_credentials_store = "file"\nmcp_oauth_credentials_store = "file"\n' > "$P/codex/config.toml"
    echo "  wrote codex/config.toml"
  fi
  [ -f "$P/npmrc" ] || run touch "$P/npmrc"

  # Git: per-profile credentials via that profile's gh login. Identity is left to you.
  if [ ! -f "$P/gitconfig" ]; then
    $DRY_RUN || printf '[credential]\n\thelper =\n\thelper = !%s auth git-credential\n' "$(command -v gh || echo /opt/homebrew/bin/gh)" > "$P/gitconfig"
    echo "  wrote gitconfig (no user yet)"
  fi

  for item in "${CLAUDE_SHARED[@]}"; do
    link "$HOME/.claude/$item" "$P/claude/$item"
  done
  if contains "$slug" "${SHARE_HISTORY[@]}"; then
    for item in "${CLAUDE_HISTORY[@]}"; do
      link "$HOME/.claude/$item" "$P/claude/$item"
    done
  fi
done
echo "✅ Profile directories ready"

# ---------- 3. Shell hooks ----------

if ! grep -q 'cli-profiles/env.zsh' "$HOME/.zshenv" 2>/dev/null; then
  $DRY_RUN || cat >> "$HOME/.zshenv" <<'EOF'

# iTerm profile isolation (see ~/.cli-profiles/env.zsh)
[[ -n $CLI_PROFILE && -r ~/.cli-profiles/env.zsh ]] && source ~/.cli-profiles/env.zsh
EOF
  echo "✅ Hook added to ~/.zshenv"
fi

if ! grep -q 'CLI_PROFILE' "$HOME/.zshrc" 2>/dev/null; then
  $DRY_RUN || cat >> "$HOME/.zshrc" <<'EOF'

# iTerm profile: own shell history and a [profile] tag in the prompt (see ~/.cli-profiles/env.zsh)
[[ -n $CLI_PROFILE_DIR ]] && HISTFILE="$CLI_PROFILE_DIR/.zsh_history"
[[ -n $CLI_PROFILE ]] && PROMPT="%F{244}[$CLI_PROFILE]%f $PROMPT"
EOF
  echo "✅ History + prompt tag added to ~/.zshrc"
fi

# ---------- 4. iTerm2 dynamic profiles ----------

run mkdir -p "$DYNAMIC_DIR"
if $DRY_RUN; then
  echo "  [dry-run] write $DYNAMIC_DIR/cli-profiles.json"
else
  sed "s|__HOME__|$HOME|g" "$ITERM_SRC/cli-profiles.json" > "$DYNAMIC_DIR/cli-profiles.json"
fi
echo "✅ iTerm2 profiles installed (work, work - preston, personal)"

echo "🎉 Done. Open a new tab from iTerm2 > Profiles, then log in per profile:"
echo "   claude, gh auth login, codex login, gcloud auth login, vercel login"
for slug in "${ISOLATED_PROFILES[@]}"; do
  if ! GIT_CONFIG_GLOBAL="$PROFILES_HOME/$slug/gitconfig" git config --global user.email >/dev/null 2>&1; then
    echo "   Set the git identity for $slug:"
    echo "     GIT_CONFIG_GLOBAL=$PROFILES_HOME/$slug/gitconfig git config --global user.name \"Your Name\""
    echo "     GIT_CONFIG_GLOBAL=$PROFILES_HOME/$slug/gitconfig git config --global user.email you@example.com"
  fi
done
