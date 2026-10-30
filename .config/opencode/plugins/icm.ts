// ICM auto-extraction + auto-recall plugin for OpenCode (V2 plugin API)
// Installed by `icm init --mode hook`, ported to OpenCode 2 hooks.
//
// Layer 0: tool.execute.after   -> extract facts from tool output
// Layer 1: session compaction   -> extract from transcript before summarization
// Layer 2: (setup log)          -> announces readiness once per load
// Layer 3: session context hook -> inject recalled context into every session
//
// V2 mapping of the old V1 hooks:
//   tool.execute.after                  -> ctx.tool.hook("execute.after")
//   experimental.session.compacting     -> ctx.session.hook("compaction")
//   session.created                     -> setup-time log (observational only)
//   experimental.chat.system.transform  -> ctx.session.hook("context")

import { Plugin } from "@opencode/plugin"
import { execFileSync, spawn } from "child_process"

// Capture tool output every N tool calls...
const EXTRACT_EVERY = 3
// ...but only drain the extraction queue (the step that loads the
// fastembed model) once per N enqueues. Issue #239: running a full
// `icm extract` on every 3rd tool call reloaded the embedding model
// from scratch each time (~3.7s CPU + a few hundred MB RAM), so
// reading many files produced visible CPU/RAM spikes. Enqueuing is
// cheap (~50ms, no model); the heavy work is batched into one
// detached drain.
const DRAIN_EVERY = 10
let toolCallCount = 0
let enqueueCount = 0

/// Enqueue raw text for deferred extraction. `icm extract --enqueue`
/// only writes a queue row — it never loads the embedding model.
function icmEnqueue(project: string, input: string): void {
  try {
    execFileSync("icm", ["extract", "--enqueue", "-p", project], {
      encoding: "utf-8",
      timeout: 10000,
      input,
      stdio: ["pipe", "pipe", "pipe"],
    })
  } catch {
    // silent — extraction is best-effort
  }
}

/// Drain the pending-extraction queue in a detached background process.
/// Fire-and-forget: the chat turn never waits on it, and the heavy
/// fastembed model load happens at most once per drain.
function icmDrainDetached(): void {
  try {
    const child = spawn("icm", ["extract-pending", "--limit", "30"], {
      detached: true,
      stdio: "ignore",
    })
    child.unref()
  } catch {
    // silent — extraction is best-effort
  }
}

/// Capture stdout of `icm <args>` synchronously. Returns the empty string on
/// any failure so a missing/old binary or empty memory store can never break
/// a chat turn.
function icmCapture(args: string[]): string {
  try {
    const out = execFileSync("icm", args, {
      encoding: "utf-8",
      timeout: 10000,
      stdio: ["ignore", "pipe", "pipe"],
    })
    return String(out).trim()
  } catch {
    return ""
  }
}

/// Pull the textual output of a completed tool call. V2 tool results carry
/// `metadata.output`, top-level `output`, or `content` text parts.
function resultText(result: any): string {
  if (!result || typeof result !== "object") return ""
  const md = result.metadata?.output
  if (typeof md === "string" && md) return md
  if (typeof result.output === "string" && result.output) return result.output
  const content = result.content
  if (typeof content === "string") return content
  if (Array.isArray(content)) {
    return content
      .filter((c: any) => c?.type === "text" && typeof c.text === "string")
      .map((c: any) => c.text)
      .join("\n")
  }
  return ""
}

export default Plugin.define({
  id: "icm",
  async setup(ctx) {
    const project = ctx.location.directory?.split("/").pop() || "project"

    // Verify icm binary is available
    let version = ""
    try {
      version = icmCapture(["--version"])
    } catch {
      version = ""
    }
    if (!version) {
      console.warn("[icm] icm binary not found in PATH — plugin disabled")
      return
    }
    console.error(`[icm] plugin loaded (${version})`)

    // De-duplicate per-session to avoid re-injecting the same wake-up pack
    // on every model turn. The context hook fires per model request; we only
    // want context once at the start of each session.
    const injectedSessions = new Set<string>()

    // Layer 0: extract facts from tool output every N calls
    await ctx.tool.hook("execute.after", (event) => {
      const tool = String(event.tool ?? "")
      if (!tool || tool.startsWith("icm") || tool.startsWith("mcp__icm__")) return

      toolCallCount++
      if (toolCallCount < EXTRACT_EVERY) return
      toolCallCount = 0

      const output = resultText((event as any).result)
      if (!output || typeof output !== "string" || output.length < 20) return

      // Enqueue only (cheap, no model load), then drain once per
      // DRAIN_EVERY enqueues in a detached process — see issue #239.
      icmEnqueue(project, output.slice(0, 8000))
      enqueueCount++
      if (enqueueCount >= DRAIN_EVERY) {
        enqueueCount = 0
        icmDrainDetached()
      }
    })

    // Layer 1: extract from the transcript before compaction
    await ctx.session.hook("compaction", (event) => {
      const messages = (event as any).messages
      if (!Array.isArray(messages)) return

      const text = messages
        .filter((m: any) => m.role === "assistant")
        .slice(-20)
        .map((m: any) => {
          if (typeof m.content === "string") return m.content
          if (Array.isArray(m.content))
            return m.content
              .filter((p: any) => p.type === "text")
              .map((p: any) => p.text)
              .join("\n")
          return ""
        })
        .join("\n")
        .slice(-4000)

      if (text.length < 50) return

      // Compaction is a natural flush point: enqueue the conversation
      // slice and drain the whole queue once in a detached process.
      icmEnqueue(project, text)
      enqueueCount = 0
      icmDrainDetached()
    })

    // Layer 3: inject recalled context into the system prompt.
    //
    // The context hook fires immediately before each agent-loop model
    // request; we append the project's wake-up pack and a project-scoped
    // recall to `event.system`, which OpenCode concatenates into the LLM's
    // system prompt.
    //
    // Run only once per session (keyed by sessionID) so we don't re-inject
    // the same context on every turn.
    await ctx.session.hook("context", (event) => {
      const sessionID = String((event as any).sessionID ?? "no-session")
      if (injectedSessions.has(sessionID)) return
      injectedSessions.add(sessionID)

      const system = (event as any).system as
        | Array<{ type: string; text: string }>
        | undefined
      if (!Array.isArray(system)) return

      // Wake-up pack: critical/high-importance facts + preferences.
      const wakeUp = icmCapture(["wake-up", "--project", project])
      if (wakeUp) {
        system.push({ type: "text", text: wakeUp })
      }

      // Project-scoped recall: top-N relevant memories for this project.
      const recalled = icmCapture(["recall-project", "--limit", "5"])
      if (recalled) {
        system.push({ type: "text", text: recalled })
        console.error(
          `[icm] injected ${recalled.split("\n").length} lines of project context into system prompt`,
        )
      }
    })

    // Layer 2 note: OpenCode V2 has no injectable per-session-create hook;
    // readiness is logged once at plugin load, real injection happens in the
    // context hook above.
  },
})
