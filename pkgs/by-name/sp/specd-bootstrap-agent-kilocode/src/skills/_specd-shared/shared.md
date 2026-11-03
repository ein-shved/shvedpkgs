# SpecD shared notes

The main session drives the work directly. Load only the procedure and source
content relevant to the current task. The [item protocol](item-work.md) defines
item authorship and independent reviews.

## Scope and sources

- Preserve the user's goal, stopping point and existing authorization. A request
  to complete the change permits continuing through design, implementation and
  verification without a new permission question at each skill boundary.
  Finish ready for closure; archive only when requested.
- Read exact referenced paths first, resolving relative paths against the
  referring resource and live values such as `changePath` against CLI output.
  Use `rg --files --hidden` or glob discovery only if that path is absent. Apply
  this to `.context` and `.specd-exploration.md` too; load relevant sections only.
- Read specs through `specd specs show <specId>` or change previews. Inspect code
  at its workspace's `codeRoot`, including external workspaces. Use graph queries
  when useful.
- Use qualified spec IDs returned by the CLI (`workspace:path`). Resolve a spec
  path with `specd specs resolve-path <path> --format toon`; do not invent IDs or
  turn slashes into colons. Choose a new spec's workspace from live configuration
  and the user's scope, asking only when the choice is material and unclear.
- Before writes, obtain workspace `ownership` and `codeRoot` from project status
  or equivalent fresh output. `readOnly` roots, including nested roots, forbid
  spec and code writes; they remain readable. External location does not alter
  permissions. Surface required readOnly work instead of working around it.

## Live state and binding context

Use `specd changes status <name> --format text` for lifecycle diagnostics. Extract
state, `changePath`, spec IDs, blockers, review reasons and next action. Use
`--format toon` for structured extraction when needed; JSON is also appropriate
when a consumer requires it. Reuse fresh output containing the needed fields;
do not repeat equivalent commands or load unrelated artifacts.

Before hooks, artifact instructions or writes, load binding context:

- Existing change: `specd changes context <name> <step> --format text`.
- Before creation or a standalone task: `specd project context --format text`.

Follow project directives and assess summary specs for relevance. Load relevant
full content with `specs show`, or `changes spec-preview` for an attached spec;
use `--artifact <id>` when one artifact suffices. Respect blocking artifacts and
warnings. After a transition reload context for the actual new step. Pass a
saved `--fingerprint <value>` only when that context is still in memory;
`unchanged` permits reuse. Changed inputs require a fresh read of affected state,
not a replay of every previous command.

Use `nextAction` and transition Repair Guides as lifecycle guidance, while
checking which artifact actually blocks the intended phase. Global
`review.required` may reflect a partial/drifted system during expected item
work: it is not itself a reason to stop implementation or return to designing.
Proposal/requirements drift must be reviewed and resolved before downstream
implementation; complete system review/validation is required before verifying
or archiving. An unchanged dependent may need state revalidation, not rewriting.
A significant inconsistency requiring a design decision pauses for the user.

## Artifacts and incremental readiness

The flow is `proposal → requirements → system ↔ code`: system and implementation
evolve together throughout each item. Revisit proposal and requirements when
scope, work items or needs evolve, preserving original authorship and aligning
dependent work. The schema and
`changes artifact-instruction` supply artifact IDs, scope, paths and composition
rules. Read `rulesPre`, `instruction` and `rulesPost` together. Fetch schema
metadata only when fresh instructions/status lack the needed fields. For delta
selectors, fetch the owning outline when needed rather than inventing structure.

Proposal owns the short numbered high-level work items and completion
checkboxes. Requirements retain needs and acceptance scenarios. System starts
with the entity's external interface and the same item skeleton, then records
brief item architecture alongside implementation. Sufficient existing
requirements/system can use `no-op` deltas, including for a one-item fix.
Create or update ADR content only when the user explicitly requests it. Preserve
existing ADR history and include requested ADR changes in applicable reviews
and final artifact validation. Ordinary work uses requirements, system and code;
do not ask for an ADR decision routinely. Follow the project's
artifact rules, referenced by binding context or artifact instructions, for
detailed content responsibilities. Record explicitly user-requested special
check descriptions in system; conduct ordinary tests and code review during
implementation.

Attach an existing owning spec even when its contracts remain unchanged. Register
it with `changes edit <name> --add-spec <specId>` before writing its artifacts.
Change scope is different from a spec dependency (`changes deps`). Declare only
real dependencies. Surface overlap warnings with affected specs/changes and
resolve their actual risk before proceeding; never silently allow archive overlap.

Inspect merged deltas using `changes spec-preview <name> <specId>`, filtered by
artifact when useful. Raw deltas alone cannot establish the resulting contract.
Review change-scoped proposal content directly. Structural validation checks
shape/state and does not replace semantic or code review:

- Change artifact: `specd changes validate <name> --artifact <id> --format text`.
- Spec artifact: `specd changes validate <name> <specId> --artifact <id> --format text`.

Validate initial proposal and requirements before implementation readiness.
Incomplete system may evolve during `implementing`; later item designs must not
delay a reviewed item's code. After all item reviews, align and validate the
complete system before `verifying` or archive. Proposal completion gates final
verification/archive, not the start of implementation.

## Hooks and transitions

Load context first. For each entered phase run its pre-hooks and then read its
pre-hook instructions; follow both before work. Finish phase work with post-hooks
and then post-hook instructions. On resume, follow current entry instructions
without a redundant transition.

For an actual transition, in order:

1. Complete source-state post-hooks/instructions if not already completed.
2. Run `changes run-hooks <name> <target> --phase pre`, then read
   `changes hook-instruction <name> <target> --phase pre --format text`.
3. Run `changes transition <name> <target> --skip-hooks all --format text`.
4. Inspect the actual state and reload its context before proceeding.

Use this ordering for intermediate states the CLI actually enters too. Never
parallelize a write/validation/hook/transition with a read depending on its effect.
If a hook or transition fails, inspect and repair the actual cause within scope.
Do not bypass CLI gates or claim completion while checks fail.

## Human gates and delivery

Never run `changes approve` yourself. CLI spec/signoff approvals are human-only
in every participation mode. At a real pending approval, give the user the exact
approval command and preserve continuation. A participation choice or review
result does not satisfy that CLI approval.

Honor project commit rules. Without such a rule or a user request, do not commit.
Keep execution evidence and concise continuation outside normative artifacts;
follow the artifact rules for system content.
