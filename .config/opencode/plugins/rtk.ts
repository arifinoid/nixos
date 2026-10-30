import { Plugin } from "@opencode/plugin"
import { execFileSync } from "child_process"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.
//
// Ported to OpenCode V2 plugin API (Plugin.define + ctx.tool.hook).

export default Plugin.define({
  id: "rtk",
  async setup(ctx) {
    let available = true
    try {
      execFileSync("which", ["rtk"], {
        encoding: "utf-8",
        timeout: 10000,
        stdio: ["ignore", "pipe", "ignore"],
      })
    } catch {
      available = false
    }
    if (!available) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", (event) => {
      const tool = String(event.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const args = event.input as Record<string, unknown> | undefined
      if (!args || typeof args !== "object") return

      const command = args.command
      if (typeof command !== "string" || !command) return

      try {
        const proc = Bun.spawnSync({ cmd: ["rtk", "rewrite", command] })
        const rewritten = String(proc.stdout).trim()
        if (rewritten && rewritten !== command) {
          args.command = rewritten
        }
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    })
  },
})
