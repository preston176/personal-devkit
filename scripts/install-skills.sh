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
  "clerk/skills@clerk-expo-patterns"
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

  # Other marketplaces
  "shadcn/ui@shadcn"
  "fallow-rs/fallow-skills@fallow"
  "harbor-framework/harbor@create-task"
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

# ---------- 3. Notes on special cases ----------

cat <<'EOF'

ℹ️  Special-case skills not handled by this script:

   • context7-mcp   → installed by `npx ctx7 setup` (run that separately;
                      it also adds the MCP server and the rule)
   • screen-demo    → 454 MB (Remotion + Steel browser deps). Install only
                      if you actually need it:
                        git clone https://github.com/preston176/screen-demo-skill.git \
                          ~/.agents/skills/screen-demo
                        bash ~/.agents/skills/screen-demo/install.sh
                      Then copy .env.example → .env and add your STEEL_API_KEY.

EOF

echo "🎉 Done. Run \`ls ~/.claude/skills\` to confirm."
