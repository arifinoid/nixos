# ECC skills as plain Agent Skills, shared by Claude Code, OpenCode, OMP, etc.
#
# The ECC CLI/plugin path is brittle here: `ecc setup` wants to rewrite
# ~/.claude/settings.json (a read-only Home Manager symlink) and fails with
# "Could not verify ecc@ecc as enabled only at user scope". Instead, pin the
# upstream repo and link ECC's curated cross-harness skill set directly into the
# shared skill directories.
#
# Discovery:
#   ~/.agents/skills  -> OpenCode, OMP, Codex/Copilot-compatible harnesses
#   ~/.claude/skills  -> Claude Code (also read by OMP/OpenCode as compat)
#
# Upstream recommends exactly this for manual installs: `.agents/skills/*` plus
# `skills/search-first` (see ECC README, "Manual install"). The remaining skills
# in `skills/` are intentionally not linked; they are harness-specific or depend
# on ECC's runtime/agents.
{
  lib,
  pkgs,
  ...
}:

let
  eccSrc = pkgs.fetchFromGitHub {
    owner = "affaan-m";
    repo = "ECC";
    rev = "90606c8315ee09cafc303515c5f33024db6b9882"; # v2.2.3
    hash = "sha256-ps8WhgXaIJMQLRwa8JgbgjAntdTWIMF3j1hpU/RKb0E=";
  };

  # Mirrors `${eccSrc}/.agents/skills` at the pinned rev. Kept explicit to avoid
  # IFD (readDir on a fetch derivation) during evaluation.
  coreSkillNames = [
    "agent-introspection-debugging"
    "agent-sort"
    "api-design"
    "article-writing"
    "backend-patterns"
    "benchmark-methodology"
    "brand-discovery"
    "brand-voice"
    "bun-runtime"
    "change-impact"
    "coding-standards"
    "competitive-platform-analysis"
    "competitive-report-structure"
    "content-engine"
    "context-and-decisions"
    "crosspost"
    "deep-research"
    "dmux-workflows"
    "docs-governance"
    "documentation-lookup"
    "e2e-testing"
    "ecc-conventions"
    "eval-harness"
    "exa-search"
    "fal-ai-media"
    "frontend-patterns"
    "frontend-slides"
    "investor-materials"
    "investor-outreach"
    "market-research"
    "mcp-dependency-review"
    "mcp-server-patterns"
    "mle-workflow"
    "module-regression"
    "nextjs-turbopack"
    "plan-canvas"
    "product-capability"
    "security-review"
    "skill-host-compat"
    "strategic-compact"
    "tdd-workflow"
    "test-collaboration"
    "unified-memory"
    "verification-loop"
    "video-editing"
    "x-api"
  ];

  skillLinks =
    lib.genAttrs coreSkillNames (name: {
      source = "${eccSrc}/.agents/skills/${name}";
    })
    // {
      search-first.source = "${eccSrc}/skills/search-first";
    };
in
{
  home.file =
    lib.mapAttrs' (name: value: lib.nameValuePair ".agents/skills/${name}" value) skillLinks
    // lib.mapAttrs' (name: value: lib.nameValuePair ".claude/skills/${name}" value) skillLinks;
}
