{ inputs, pkgs, ... }:

# CodeBuddy Code (cbc) hook wiring for rtk + icm.
#
# rtk and icm only ship integrations for Claude Code, so two thin wrappers sit
# between them and CodeBuddy:
#
#   rtk-pretool.sh  pass-through to `rtk hook claude`. CodeBuddy reads the
#                   rewrite from `hookSpecificOutput.updatedInput` (same field
#                   rtk emits), so no translation is needed.
#   icm-hook.sh     forwards one subcommand (pre/post/compact/prompt/start/end)
#                   and swallows failures, since icm only officially supports
#                   Claude Code / Claude Desktop.
#
# settings.json itself lives in .config/codebuddy/settings.json so it stays
# readable and diffable; hook commands reference the wrappers by $HOME path.
let
  agentCli = pkgs.callPackage "${inputs.self}/nix/packages/agent-cli.nix" { };

  rtkPretool = pkgs.writeShellScript "codebuddy-rtk-pretool" ''
    # Empty stdout means "no rewrite" (non-Bash tool, or a command rtk does
    # not know how to compact), which leaves the original call untouched.
    exec ${agentCli.rtk}/bin/rtk hook claude
  '';

  icmHook = pkgs.writeShellScript "codebuddy-icm-hook" ''
    set -u

    [ $# -eq 1 ] || exit 0
    ${agentCli.icm}/bin/icm hook "$1" 2>/dev/null || exit 0
  '';
in
{
  home.file.".codebuddy/hooks/rtk-pretool.sh".source = rtkPretool;
  home.file.".codebuddy/hooks/icm-hook.sh".source = icmHook;

  # CodeBuddy rewrites these files with a temp-file + rename, which replaces
  # the Nix symlink with a regular file (it does not respect the read-only
  # bit like Claude Code does). `force` makes activation relink them instead
  # of failing on a backup collision. App-side edits are reverted on rebuild.
  home.file.".codebuddy/settings.json" = {
    source = "${inputs.self}/.config/codebuddy/settings.json";
    force = true;
  };
  home.file.".codebuddy/.mcp.json" = {
    source = "${inputs.self}/.config/codebuddy/.mcp.json";
    force = true;
  };
}
