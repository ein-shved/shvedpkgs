---
name: "specd-compliance"
description: "Run specs-compliance review between implementation and specs."
---

# specd-compliance

Before any shared-notes lookup or glob discovery, check referenced exact paths.
Resolve relative paths against the referring resource and known values such as
`changePath` against live CLI output. Test/read the resolved path first; use
`rg --files --hidden` or glob fallback only when it is genuinely absent. Apply
this to shared resources, `.context`, and `.specd-exploration.md` too.

Start or resume a separate manager with [manager.md](../_specd-shared/manager.md),
the invoked skill `specd-compliance`, arguments, project root/config, and relevant source
pointers. The manager loads [the procedure](../_specd-shared/workflows/specd-compliance.md)
and [shared notes](../_specd-shared/shared.md). Ask for the current bounded
assignment; do not load the full procedure into the author context by default.
Do not spawn a manager from a worker already assigned that manager role.

As executor, independently read the assigned sources and applicable criteria,
perform the bounded work, self-review, and report the output/revision to the
manager. Follow its live ownership, scope, hooks, review, approval, and stop
conditions. It cannot expand user authorization or filesystem permissions.
Preserve sequential task completion and the approved plan's checkbox-only rule.
For design, resolve participation before authoring; in delegated mode the main
session loads [coordinator.md](../_specd-shared/coordinator.md) and launches a
separate scoped executor, including handoff of any unfinished main-authored draft.

At the manager's three review triggers, launch a separate arbiter with
[arbiter.md](../_specd-shared/arbiter.md) and its concise source/revision assignment.
The arbiter reads sources directly and never edits artifacts. Sequential owner
comments use executor self-review; retain one arbiter within a launched cycle.
Final review and decision-owner acceptance cover the same revision before
structural validation or subscope closure. Human-only CLI gates remain human.

Use the client's supported independent-agent tools and available slots. For
KiloCode, use independent task/subagent facilities when exposed;
start workers without inherited conversation. Stop workers before a group
handoff. If independent contexts are unavailable, save continuation under the
live change path and report the limitation. Manual user-created primary
sessions support involved-mode handoff; compaction or role relabeling does not.
Continue design with `/specd-design <name>` when the manager names that boundary.
Invoke skills with `/specd-compliance` (and other `/specd-*` names); translate slash-style
CLI recommendations to this client syntax.

The manager names the terminal boundary. Stop there and suggest the next skill;
do not invoke another lifecycle skill without an explicit user request.
