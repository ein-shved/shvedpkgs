# specd-design — manager-loaded design procedure

Read `../shared.md`; use this procedure under `../manager.md`. Return bounded
executor assignments. Schema artifact instructions own content rules; SpecD
owns state. The author loads only its relevant sources and criteria.

## 1. Live state, context, and ownership

Run `specd changes status <name> --format text`. Extract the live lifecycle path,
spec IDs, artifact DAG, review reasons, blockers and next action. If review is
required, inspect the named drifted/affected artifacts first against current
intent; downstream pending-review alone does not justify rewriting them.
Follow diagnostic Repair Guides, stopping after a redirect or failed transition.

Before any hook or artifact instruction, load:

```bash
specd changes context <name> designing --follow-deps --depth 1 --rules --constraints --format text [--fingerprint <stored-value>]
specd project status --format toon
```

Process all binding directives and relevant summary specs. Store the context
fingerprint; reload after transitions, using it only as the documented freshness
signal. Get workspace ownership/codeRoot and each spec's workspace. Before every
write check readOnly roots, including nested roots. They are off-limits to spec
writes, proposed implementation targets, and code edits. Surface any required
readOnly work and stop. External workspace location changes no permissions:
read specs via CLI and code via its codeRoot.

For drafting/designing, run designing pre-hooks then hook-instruction, follow
them, and transition with `--skip-hooks all` if needed. On resume rerun pre-hooks
without a redundant transition. For other states use live next action; obtain
explicit authority for a return to design when not already authorized. Finish
the source-state post-hooks before a transition, target pre-hooks before it,
and reload context afterward. Never let transitions run hooks implicitly.

Run `specd schema show --format toon` unless a fresh artifact-instruction or
structured status already contains the exact metadata needed: IDs, scope,
optional/delta flags, hasTasks, validation rules and output paths. Do not guess
filenames. One spec at a time for spec-scoped artifacts; register a spec with
`changes edit --add-spec` before writing its delta. Stop on overlap warnings and
surface affected specs/changes for the user's decision as shared notes require.

## 2. Sources and participation before authoring

Check exact `<changePath>/.context` and `.specd-exploration.md` before discovery.
Read only relevant sections, checking paths, spec IDs and decisions against live
sources. Stale notes grant no authority. If discovery context is absent, gather
the missing facts and save concise verifiable discovery before writing. Surface
material drift for resolution; do not quietly follow a rejected old decision.

Before assigning proposal authoring, offer the real user once:

- "I want to participate in design" — involved: you discuss decisions and accept
  each content revision.
- "I delegate design to the agent" — delegated: a coordinator decides and accepts
  within your goal and constraints, returning for missing input or authority.

Reuse a clear prior choice, including an explicit request to handle design
without involving the user. An all-at-once/fast-forward/`--ff` request only sets
batch scheduling. It does not select delegated mode or approve draft content.
Do not ask another one-artifact/all-at-once questionnaire. The default scheduling
follows category; record explicit batch requests as exceptions.

Record `Participation: involved|delegated` in proposal and its current pointer,
decision owner and batching preference in `.context`. For older proposals
without this field resolve participation before assigning unfinished design.
If entering delegated mode, the main session reads `../coordinator.md` and
becomes coordinator. Hand any unfinished scope and existing draft to a separate
executor without inherited conversation. That author independently reads inputs
and verifies or revises the draft before coordinator acceptance. Completed
scopes stay closed when mode alone changes. Mode selection approves no content.

Give a concise context summary: change/goal, specs, completed artifacts and
current scope. Resolve substantive ambiguity with the current decision owner.
Keep ordinary corrections within that scope without repeated permission-to-
continue questions.

## 3. Choose the current bounded scope

```bash
specd changes artifact-instruction <name> --format toon
```

Read rulesPre -> instruction/template/delta -> rulesPost as one mandatory block.
If `delta.availableOutlines` names specs, retrieve real selector structure with
`specd specs outline <specId> --artifact <id>` (add `--full`/`--hints` as needed)
before writing deltas. Never invent selectors or spec IDs. Use schema metadata
for exact target paths. Optional artifacts are decided by the decision owner;
if unnecessary use `changes skip-artifact <name> <id>`.

Before relevant graph queries check `specd graph stats --format toon`; index
if stale/unindexed. Search related specs/symbols and hotspots when code is in
scope. For plan targets run dependent impact and include findings in plan.
Reuse a fresh equivalent impact result for the same target set; new targets
need fresh analysis. Surface HIGH/CRITICAL findings before continuing.

The proposal estimates independent decisions and records category/reason.
Apply its compact numbered allocation and stable correction replay. Requirements
consume that accepted table without another intent checkpoint. If new decisions
materially change allocation/category, return affected proposal content to
review first and reconsider dependent artifacts.

Group lifetime follows the actual category in both participation modes:

| Category | Scheduling |
| --- | --- |
| small change | May retain executor/manager from proposal through plan. |
| large architectural development | Fresh group per artifact and system scope. |

Keep the group throughout discussion of the current scope. In involved mode,
a completed large scope strongly recommends a fresh primary user-created session
for the named next scope and stops. In delegated mode the persistent coordinator
launches the next fresh author/manager group without inherited conversation.
Explicit user-directed batching can keep the current primary session; retain
per-artifact review and validation order and record this exception.

## 4. Author, review, accept and validate

Assign only the current artifact or agreed system subscope, sources, target,
criteria and completion conditions. Do not prepare later artifacts in advance.
Write files sequentially; create directories only if a target write needs them.
Use deltas for existing specs and template scaffolds for new ones. Afterwards
check whether scope needs correction with `specd specs list --format text --summary`.
Review a spec delta via `changes spec-preview <name> <specId> --artifact <id>`;
review proposal/plan directly. No-op means review of the unchanged base.

The executor applies composition checks and specific artifact boundary self-review
before reporting the first completed draft. Correct wrong statements and their
dependent explanations, then reread the whole affected section. Describe the
current account directly; remove residual contrasts/correction history and
unsupported negative claims while preserving independently imposed constraints.
Accept sufficient compact contracts; request expansion only for a concrete
ambiguity. Confirm real asserted automated coverage and preserve uncovered
manual duties. Routine self-assessment adds no report or artifact section.

Apply `../manager.md` review scheduling exactly:

1. First completed draft: fresh arbiter independently checks the named sources
   and identified merged/content revision before owner presentation.
2. During owner feedback: executor corrects with self-review; consecutive typo
   or substantive comments launch no new arbiter. Keep manager available.
3. Owner accepts current content: fresh final arbiter checks that revision.
4. Explicit user/coordinator request: fresh arbiter checks the requested content;
   the request itself does not approve it.

Within one cycle keep that arbiter for corrections, using revision pointers and
changed inputs; close it on success or escalation. Escalate conflict with
approved inputs, material intent or nonconvergence without silently reversing
owner decisions. If final findings change text, show the diff to the owner and
obtain acceptance of that revision. Require final arbiter success and actual
owner approval on the same revision before validation/subscope closure. In
involved mode wait for real-user content acceptance. In delegated mode record
the coordinator's actual acceptance after it reads that revision. Preserve
human-only CLI spec/signoff gates for the real user.

Only then run the scope-appropriate structural command in text format:

```bash
specd changes validate <name> --artifact <change-artifact-id> --format text
specd changes validate <name> <specId> --artifact <spec-artifact-id> --format text
```

If validation needs changed content, including upstream repairs, show the diff
and return it to the decision owner; approval plus final review must match the
repaired revision before revalidation. Do not silently edit/validate unapproved
upstream content. Reuse unchanged reviewed content's approval for state-only
repairs. Technical inspections can run before acceptance. Batch drafting still
requires each artifact's concrete acceptance before its structural validation.
Re-read needed live state after writes/validation; use review reasons to decide
whether other artifacts actually need content updates.

## 5. Large system scopes

Before detailed subsystem design, assign an overview: actors, subsystem
responsibilities, external/inter-subsystem interfaces, relationships, main flows,
and requirement links. Prepare pending subsystem skeletons with known inputs
and open questions. Record ordered overview/subsystem/integration scopes and
revision-specific review states in `.context`. These are sections of one system
artifact, not new artifact IDs or invented CLI states.

Review/accept the overview by the same triggers, then close that subscope without
whole-system structural validation. Pending sections are visibly incomplete and
cannot serve as complete downstream contracts. Each subsystem gets a fresh group
focused on its section, overview, requirements and relevant interfaces. Surface
contradictions affecting approved interfaces for owner review and reconsider
affected prior/dependent scopes; keep unrelated areas closed. Record the changed
input revisions and invalidate stale dependent acceptance in continuation.

After all affected sections complete, review the integrated system revision.
The last subsystem group may integrate and close it if no independent design
scope is needed; otherwise use a fresh integration group. Apply the first-draft,
owner-acceptance and explicit-request triggers to integration review as well.
Only the complete reviewed system goes to structural validation. Do not author
validate or plan against incomplete system sections.

## 6. Close scope and continue

After actual owner acceptance/final review and applicable validation, record
concise continuation: current/next scope, input links/revisions, participation,
decision owner, author identity, approval/review revisions, active decisions,
questions and system scope/integration states. Stop workers before handoff.
New groups verify live CLI state and relevant source freshness, loading only
needed sections. `.context` records acceptance; its presence alone grants none.

Run one group at a time within the client's independent-agent slots. If required
contexts/session controls are unavailable, save pointers and report the boundary.
Never count compaction or relabeling as fresh context. In involved large design,
strongly recommend a new primary session with `$specd-design <name>` and the
context pointer, then stop without another permission question. Explicit batch
exceptions may continue within the reviewed scheduling preference. Delegated
coordinators launch fresh groups as above, progressing within delegated design.

When all artifacts finish, immediately run designing post-hooks and their
instruction. Check the exact planned implementation target set's dependent
impact (reuse a fresh exact result); surface HIGH/CRITICAL findings and resolve
before proceeding. Reload/reuse fresh ownership with all codeRoot/ownership
fields: block readOnly targets, surface out-of-scope targets and wait for scope
authority. Do not enter ready with blocked implementation targets.

Run ready pre-hooks/instruction; transition with `--skip-hooks all`; reload
context for the new state; immediately run ready post-hooks/instruction.
Read `changes status <name> --format text`. Follow Repair Guides on failure and
stop after redirects. For a human-only spec gate tell the real user the exact
`specd changes approve spec <name> --reason "..."` command and stop; never run it.
Report completed design and unresolved matters, suggest `$specd-implement <name>`,
and stop. Do not invoke implementation automatically, including delegated mode.
