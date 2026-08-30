#!/usr/bin/env bash
#
# Install all Claude Code skills used in this setup.
#
# Two sources:
#   1. Marketplace skills via the `npx skills` CLI (skills.sh ecosystem).
#   2. Standalone skills copied directly from claude/skills/ into ~/.claude/skills/.
#
# Run after scripts/install.sh. Re-running is idempotent (npx skills add is a
# no-op on already-installed skills; cp -R will overwrite copies in place).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/claude/skills"
SKILLS_DST="$HOME/.claude/skills"

echo "🧠 Installing Claude Code skills..."

# ---------- 1. Marketplace skills (via npx skills) ----------

MARKETPLACE_SKILLS=(
  # Clerk family (auth) — github.com/clerk/skills
  "clerk/skills@clerk"
  "clerk/skills@clerk-setup"
  "clerk/skills@clerk-android"
  "clerk/skills@clerk-astro-patterns"
  "clerk/skills@clerk-backend-api"
  "clerk/skills@clerk-billing"
  "clerk/skills@clerk-chrome-extension-patterns"
  "clerk/skills@clerk-custom-ui"
  "clerk/skills@clerk-expo"
  "clerk/skills@clerk-nextjs-patterns"
  "clerk/skills@clerk-nuxt-patterns"
  "clerk/skills@clerk-orgs"
  "clerk/skills@clerk-react-patterns"
  "clerk/skills@clerk-react-router-patterns"
  "clerk/skills@clerk-swift"
  "clerk/skills@clerk-tanstack-patterns"
  "clerk/skills@clerk-testing"
  "clerk/skills@clerk-vue-patterns"
  "clerk/skills@clerk-webhooks"

  # Vercel Labs — github.com/vercel-labs/agent-skills + vercel-labs/skills
  "vercel-labs/skills@find-skills"
  "vercel-labs/agent-skills@deploy-to-vercel"
  "vercel-labs/agent-skills@vercel-cli-with-tokens"
  "vercel-labs/agent-skills@vercel-composition-patterns"
  "vercel-labs/agent-skills@vercel-react-best-practices"
  "vercel-labs/agent-skills@vercel-react-native-skills"
  "vercel-labs/agent-skills@vercel-react-view-transitions"
  "vercel-labs/agent-skills@web-design-guidelines"

  # Expo / EAS — github.com/expo/skills
  "expo/skills@expo-router"
  "expo/skills@expo-project-structure"
  "expo/skills@expo-ui"
  "expo/skills@expo-native-ui"
  "expo/skills@expo-dom"
  "expo/skills@expo-web-to-native"
  "expo/skills@expo-data-fetching"
  "expo/skills@expo-tailwind-setup"
  "expo/skills@expo-dev-client"
  "expo/skills@expo-module"
  "expo/skills@expo-migrate-module"
  "expo/skills@expo-brownfield"
  "expo/skills@expo-app-clip"
  "expo/skills@expo-upgrade"
  "expo/skills@expo-examples"
  "expo/skills@expo-skill-eval"
  "expo/skills@expo-skill-feedback"
  "expo/skills@eas-workflows"
  "expo/skills@eas-hosting"
  "expo/skills@eas-update-insights"
  "expo/skills@eas-observe"
  "expo/skills@eas-simulator"
  "expo/skills@eas-app-stores"

  # Other marketplaces
  "shadcn/ui@shadcn"
  "fallow-rs/fallow-skills@fallow"
  "harbor-framework/harbor@create-task"
  "pstack/skills@unslop"

  # Grilling (github.com/mattpocock/skills)
  # grill-me is only the /grill-me entrypoint; it calls `grilling`, so install both.
  "mattpocock/skills@grilling"
  "mattpocock/skills@grill-me"

  # Test-driven development (github.com/mattpocock/skills)
  "mattpocock/skills@tdd"
)

for skill in "${MARKETPLACE_SKILLS[@]}"; do
  echo "  → $skill"
  npx -y skills add "$skill" -g -y || echo "    (skipped: install failed or already present)"
done

echo "✅ Marketplace skills processed (${#MARKETPLACE_SKILLS[@]} packages)"

# ---------- 2. Standalone skills (copied from claude/skills/) ----------

mkdir -p "$SKILLS_DST"

if [ -d "$SKILLS_SRC" ]; then
  echo "📂 Copying standalone skills from claude/skills/..."
  for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    cp -R "$skill_dir" "$SKILLS_DST/$name"
    echo "  → $name"
  done
  echo "✅ Standalone skills copied to $SKILLS_DST"
fi

# ---------- 3. Own skills (cloned from GitHub, symlinked in) ----------
#
# Skills I maintain in my own repos. Cloned into ~/Code/personal/ and
# symlinked into ~/.claude/skills/ so edits round-trip via `git push`.

OWN_SKILLS_DIR="$HOME/Code/personal"
mkdir -p "$OWN_SKILLS_DIR"

declare -a OWN_SKILLS=(
  "nextjs-structure|https://github.com/preston176/nextjs-structure.git"
)

echo "🔧 Linking own skills..."
for entry in "${OWN_SKILLS[@]}"; do
  name="${entry%%|*}"
  url="${entry##*|}"
  target="$OWN_SKILLS_DIR/$name"
  link="$SKILLS_DST/$name"

  if [ ! -d "$target" ]; then
    git clone "$url" "$target"
  fi
  if [ ! -e "$link" ]; then
    ln -s "$target" "$link"
    echo "  → $name (symlinked)"
  else
    echo "  → $name (already linked)"
  fi
done

# ---------- 4. Impeccable (its own npm CLI, not the skills marketplace) ----------
#
# Ships its own installer, so `npx skills add` cannot fetch it. Two things to
# know: `--providers claude` keeps it out of ~/.codex, ~/.cursor and ~/.gemini,
# and the installer writes PostToolUse + Stop hooks into
# ~/.claude/settings.local.json. Without --global it installs into the current
# project instead, and will also target .github/ if the repo has a .github
# folder, which is rarely what you want.

echo "🎨 Installing impeccable (design skills + anti-pattern detection)..."
npx -y impeccable@latest install --global --providers claude --yes \
  || echo "  (skipped: install failed or already present)"

# ---------- 5. Notes on special cases ----------

cat <<'EOF'

ℹ️  Special-case skills / plugins not handled by this script:

   • context7-mcp   → installed by `npx ctx7 setup` (run that separately;
                      it also adds the MCP server and the rule)

   • screen-demo    → 454 MB (Remotion + Steel browser deps). Install only
                      if you actually need it:
                        git clone https://github.com/preston176/screen-demo-skill.git \
                          ~/.agents/skills/screen-demo
                        bash ~/.agents/skills/screen-demo/install.sh
                      Then copy .env.example → .env and add your STEEL_API_KEY.

   • Plugins        → installed inside Claude Code, not via shell. Run:
                        /plugin marketplace add anthropics/claude-code
                        /plugin install superpowers
                        /plugin install pr-review-toolkit
                      superpowers bundles ~14 process skills (brainstorming,
                      systematic-debugging, TDD, writing-plans, etc.).
                      pr-review-toolkit adds /review-pr + review subagents.

EOF

echo "🎉 Done. Run \`ls ~/.claude/skills\` to confirm."
