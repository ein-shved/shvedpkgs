# specd-implement — write code

Manager-loaded procedure. Read `../shared.md` relative to this resource.
Use this procedure to issue bounded executor assignments under `../manager.md`.
Load binding context before any hooks/instructions; reload after transitions.
Preserve live ownership, review, approval, graph, and terminal-stop guards.

## What this does

Implements the code described by the change's requirements, system, plan, and tasks artifacts.
Works through tasks one by one and marks them done.

## Steps

### 1. Load change state

```bash
specd changes status <name> --format text
```

Identify any high-visibility blockers from the **blockers:** section (e.g. `ARTIFACT_DRIFT`,
`OVERLAP_CONFLICT`, `REVIEW_REQUIRED`) and inform the user. Follow the **next action:**
command recommendation.

Extract the `path:` field from the "lifecycle:" section.
From the `artifacts (DAG):` section, note which artifact IDs are marked with
`[hasTasks]`; those are the task-bearing artifacts to read and update later.

If the status output shows `review: required: yes`, this change has artifacts that
require review before implementation can continue. Tell the user:

> Artifacts need review before implementation can continue. Run `/specd-design <name>`.

**Stop — do not continue.**

If not in `ready` or `implementing` or `spec-approved`, this is the wrong skill.
Redirect based on the **next action:** `target` recommendation.

**Stop — do not continue.**

If in `ready` or `spec-approved`, run pre-hooks and transition:

```bash
specd changes run-hooks <name> implementing --phase pre
specd changes hook-instruction <name> implementing --phase pre --format text
```

Follow guidance — it tells you which change artifacts to read.

```bash
specd changes transition <name> implementing --skip-hooks all
```

If already in `implementing` (resuming), run pre-hooks but skip the transition:

```bash
specd changes run-hooks <name> implementing --phase pre
specd changes hook-instruction <name> implementing --phase pre --format text
```

### 2. Check workspace ownership

```bash
specd project status --format toon
```

From the response, build a map of each workspace's `codeRoot` and `ownership` from the `workspaces` array.
For each `specId` in the change, determine which workspace it belongs to.

**If any spec targets a `readOnly` workspace:**

> **Blocked.** The following specs belong to readOnly workspaces and cannot be modified:
>
> | Spec | Workspace | codeRoot |
> | ---- | --------- | -------- |
> | ...  | ...       | ...      |
>
> Remove them from the change or update the workspace ownership in `specd.yaml`.

**Stop — do not continue.**

**Continuous guard — applies throughout the entire implementation session:**

ReadOnly workspaces are off-limits. You must NOT write or edit any file under
the `codeRoot` of a readOnly workspace. Before every file write or edit, verify
the target path does not fall within a readOnly `codeRoot`.

If a task requires modifying code in a readOnly workspace, **stop immediately** —
do not implement it, do not work around it, do not assume it's okay. Surface it
to the user. The design may need revision, or the workspace ownership must change
in `specd.yaml` before you can proceed.

### 3. Locate task-bearing artifacts

Use the `[hasTasks]` artifact IDs noted from the initial change status output.

### 4. Load context

```bash
specd changes context <name> implementing --follow-deps --depth 1 --rules --constraints --format text [--fingerprint <stored-value>]
```

Pass `--fingerprint <stored-value>` if you have a `contextFingerprint` from a previous `changes context` call in this conversation (see `shared.md` — "Fingerprint mechanism"). If output says `unchanged`, use the context already in memory.

**MUST follow** — project context entries are binding directives. If lazy mode returns
summary specs, evaluate each one and load any that are relevant to the code you're
about to write (see `shared.md` — "Processing `changes context` output").

### 4b. Check impact coverage

Before coding, confirm the plan artifact already includes impact analysis for the files or
symbols named by the tasks. Reuse that analysis as the implementation baseline.

Run additional graph impact commands only when implementation discovers a target file
or symbol that was not covered by the plan artifact, when the task scope has changed, or when
fresh status/context indicates the artifacts may be stale:

```bash
specd graph impact --symbol "<name>" --direction dependents --format toon
specd graph impact --file "<workspace:path>" --direction dependents --format toon
```

Surface newly discovered HIGH or CRITICAL risk findings to the user before continuing.

### 5. Read change artifacts

Read ALL change artifacts from `<changePath>/`:

- **Change-scoped** artifacts — directly in `<changePath>/`
- **Spec-scoped deltas** — in `<changePath>/deltas/` (existing specs modified by this change)
- **Spec-scoped new specs** — in `<changePath>/specs/` (new specs created by this change)

Do not hardcode filenames — use the schema's artifact definitions.

### 6. Work through tasks

#### 6a. Plan execution order

Read all tasks and upstream artifacts. Map dependencies and shared-file conflicts
and present the execution order before starting. Execute top-level plan items in
the approved order. A later item starts after the current item's implementation
and completion evidence are complete.

#### 6b. Execute the current item

Implement the current item, run its required checks, then immediately mark only
its checkbox done (`- [ ]` -> `- [x]`). Keep evidence and temporary tracking
outside the approved plan. Consult artifacts for ambiguity and surface any work
outside the change's spec scope. Mark progress in real time.

Independent subtasks inside the current item may use supported worker tools when
available and authorized. Include exact task/source pointers, applicable criteria,
output paths and completion evidence. Keep writes isolated (for example through
separate checked-out worktrees when supported) and respect available agent slots.
Do not prescribe an API the client lacks; use sequential execution when isolation
or capacity is unavailable. Workers return results to the executor, which reviews
and integrates them and owns the top-level checkbox. Do not run later plan items
in parallel or let workers complete their checkboxes out of order.

### 7. Run exit hooks — immediately after last checkbox

**Trigger:** the moment the last `- [ ]` across ALL task-bearing artifacts is marked
`- [x]`, run the post-implementing hooks.

```bash
specd changes run-hooks <name> implementing --phase post
specd changes hook-instruction <name> implementing --phase post --format text
```

Follow guidance. If hooks fail (tests, lint), fix and re-run until they pass.

> Implementation complete. Run `/specd-verify <name>` to verify against scenarios.

**Stop.**
Do not invoke `/specd-verify` automatically; wait for explicit user confirmation.

## Session tasks

1. `Load state & hooks`
2. `Load context & artifacts`
3. For each task item: `Implement: <task summary>`
4. `Run exit hooks`

## Handling failed transitions

When `changes transition` fails, it renders a **Repair Guide** in text mode.
Follow the recommended repair command based on the target recommendation.

**Stop — do not continue after redirecting.**

## Returning to design

If during implementation you discover that the artifacts need changes, stop and explain
the issue. If the user agrees:

```bash
specd changes transition <name> designing --skip-hooks all
```

> Artifacts need revision. Run `/specd-design <name>` to update them.

**Stop — do not continue implementing.**

## Guardrails

- Mark tasks done in real time — don't batch checkbox updates
- The change artifacts are the source of truth for implementation approach
- If you touch code outside the change's spec scope, surface it to the user
- Never skip the pre-hook — it tells you what to read
- Any time a fresh `changes status` shows `review: required: yes`, stop
  implementation and redirect to `/specd-design <name>`
