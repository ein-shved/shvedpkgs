# specd-new — discover and create

Manager-loaded procedure. Read `../shared.md` relative to this resource.
Use this procedure to issue bounded executor assignments under `../manager.md`.
Load binding context before any hooks/instructions; reload after transitions.
Preserve live ownership, review, approval, graph, and terminal-stop guards.

## What this does

Explores what the user wants to accomplish, surfaces affected specs, and creates a
change when the picture is clear. Does NOT write any artifacts — that's `/specd-design`.

## Steps

### 1. Load project context

```bash
specd project context --format text
```

**MUST follow** — project context entries are binding directives. If lazy mode returns
summary specs, evaluate and load any that are relevant to the work ahead
(see `shared.md` — "Processing `changes context` output").

**Workspace locality rule — mandatory.** External workspaces are still part of the
project for discovery work.

- Read **specs** through specd CLI commands only. Do NOT inspect specs directly from
  `specsPath`, whether the workspace is local or external.
- Read **code** directly from a workspace's `codeRoot` when you need to understand
  current behavior, dependencies, or likely impact, even if that `codeRoot` lives
  outside the current git root.
- `isExternal` does not change permissions; it only tells you the workspace lives
  outside the current repository root.
- `ownership` controls writes, not reads. `readOnly` workspaces may still be inspected
  for context.

### 2. Understand intent

**Do NOT immediately ask for a name, description, or specIds.**

- If the user explained clearly (in arguments or prior messages): summarize and confirm.
- If vague: have a conversation. Ask what you need to understand:
  - What problem are they solving?
  - What's the approach?
  - What areas of the codebase are affected?

Investigate the codebase if relevant:

```bash
specd specs list --format text --summary
```

Surface existing specs that might be affected. Let the conversation develop naturally.

When a likely affected workspace is external, inspect its code via `codeRoot` the same
way you would inspect local workspace code. Do not skip it just because it lives in a
different repository directory.

#### Use code graph for deeper investigation

When the user describes affected areas, use graph search to find related symbols and specs:

```bash
specd graph search "<keyword>" --format toon
```

If the user mentions specific files or symbols, check their impact to understand scope:

```bash
specd graph impact --file "<workspace:path>" --direction both --format toon
specd graph impact --symbol "<name>" --direction both --format toon
```

This helps you surface specs and code areas the user may not have considered. If `riskLevel`
is HIGH or CRITICAL, mention it — it affects how many specs should be in scope.

### 3. Propose the change

When the picture is clear enough, first check workspace ownership:

```bash
specd project status --format toon
```

If a fresh command in this same skill execution already returned `workspaces` with
`ownership` and `codeRoot`, reuse that output instead of running this command again.
Do not reuse project context alone unless it contains those exact fields.

From the response, build a map of each workspace's `ownership` from the `workspaces` array. For each spec you're
about to propose, determine which workspace it belongs to.

**If any proposed spec belongs to a `readOnly` workspace**, do NOT include it. Tell the user:

> `<workspace:spec-path>` belongs to workspace `<workspace>` which is `readOnly` —
> it can't be modified by a change. Want to use it as context instead, or change
> the workspace ownership in `specd.yaml`?

Only propose specs from `owned` or `shared` workspaces:

> Based on our discussion:
>
> - **Name:** `<kebab-case-slug>`
> - **Description:** `<one-liner>`
> - **Initial specs:** `<workspace:path>, ...` (or none yet — we can add them during design)
>
> Want me to create this change?

Wait for confirmation.

### 4. Create

```bash
specd changes create <name> --spec <workspace:path> --description "<desc>" --format toon
```

The response includes `changePath` — the directory where artifacts will be written.

If `changes create` fails with `Change '<name>' already exists`, the change is already
in progress. Load its status in **text mode** for diagnostics and **toon mode** for extraction:

```bash
specd changes status <name> --format text
specd changes status <name> --format toon
```

Read `state`, `blockers`, `nextAction`, and `review` from the response.

**Always prioritize high-visibility blockers.** If `blockers` is not empty,
identify which ones are blocking progress (e.g. `ARTIFACT_DRIFT`, `OVERLAP_CONFLICT`,
`REVIEW_REQUIRED`) and inform the user. Follow the `nextAction.command`
recommendation.

If `review.required` is `true`, suggest `/specd-design <name>` regardless of
the lifecycle state. Summarize `review.reason` and `review.affectedArtifacts`,
then stop.

If `review.required` is `false`, suggest based on `nextAction.targetStep`:

| targetStep                       | Suggest                                                                     |
| -------------------------------- | --------------------------------------------------------------------------- |
| `drafting` / `designing`         | `/specd-design <name>`                                                      |
| `ready`                          | Review artifacts, then `/specd-implement <name>` if approved                |
| `implementing` / `spec-approved` | `/specd-implement <name>`                                                   |
| `verifying`                      | `/specd-verify <name>`                                                      |
| `done` / `signed-off`            | `/specd-verify <name>` (handles done→archivable transition)                 |
| `pending-signoff`                | "Signoff pending. Run: `specd changes approve signoff <name> --reason ...`" |
| `archivable`                     | `/specd-archive <name>`                                                     |
| `pending-spec-approval`          | "Approval pending. Run: `specd changes approve spec <name> --reason ...`"   |

**Stop — do not continue.**

### 5. Run entry hooks

```bash
specd changes run-hooks <name> drafting --phase pre
specd changes hook-instruction <name> drafting --phase pre --format text
```

Follow guidance if any.

### 6. Register known spec dependencies

If during the discovery conversation you identified dependencies between the specs in the
change (or between them and existing specs), register them now:

```bash
specd changes deps <name> <specId> --add <depId> --add <depId>
```

This is optional at this stage — dependencies can also be registered later during
`/specd-design` when the proposal is written. But if the conversation already surfaced
clear dependencies, registering them early means the context compilation will be richer
from the start.

### 7. Save exploration context

Write a file `.specd-exploration.md` inside the change directory (`<changePath>/.specd-exploration.md`).
This file is discovery memory outside the artifact DAG. Capture the goal,
constraints, verified observations and paths/spec IDs, active decisions and
reasons, unresolved questions, and relevant rejected alternatives. Keep it
scannable; do not automatically replay full discussion into later author groups.
Put concise current/next-scope pointers in change-local `.context`. Neither
support note replaces normative artifacts or grants content acceptance.

**Staleness awareness.** Time may pass between exploration and design — code may change,
specs may be renamed or removed, and decisions may no longer apply. To help the future
reader judge freshness:

- Include **concrete anchors**: file paths, spec IDs, function names, line numbers when
  relevant. These are verifiable — the reader can check if they still exist.
- Note **why** each decision was made, not just what was decided. Reasons age better than
  conclusions — if the reason still holds, the decision likely does too.
- Timestamp the file (add a `Generated: YYYY-MM-DD` line at the top).

Write it in plain markdown, structured for quick scanning. This is for agent use, not
user documentation — optimize for completeness and precision over polish. When in doubt
about whether to include something: include it.

### 8. Run exit hooks

```bash
specd changes run-hooks <name> drafting --phase post
specd changes hook-instruction <name> drafting --phase post --format text
```

Follow guidance if any.

### 9. Show status and stop

```bash
specd changes status <name> --format text
specd changes status <name> --format toon
```

Show the change state and suggest next step:

> Change `<name>` created at `<changePath>`.
> Run `/specd-design <name>` to start writing artifacts.

**Stop here.** Do not start writing artifacts.
Do not invoke `/specd-design` automatically; wait for explicit user confirmation.

## Session tasks

Create tasks at the start for session visibility. Update them as you go.

1. `Load project context` — mark done after step 1
2. `Understand intent` — mark done after confirming what the user wants
3. `Propose change` — mark done after user confirms name/description/specs
4. `Create change` — mark done after CLI creates the change successfully
5. `Save exploration context` — mark done after writing `<changePath>/.specd-exploration.md`

## Guardrails

- Do NOT write any code — this skill is for discovery and change creation only
- Do NOT modify any existing files in the codebase
- Do NOT create artifacts — that's `/specd-design`
- Do NOT skip the discovery conversation to rush to creation
- Spec IDs must be `workspace:capability-path` — look up from `specs list`, never guess
- It's fine to create with no specs — they can be added during design
- For new specs, ask the user which workspace they belong to
