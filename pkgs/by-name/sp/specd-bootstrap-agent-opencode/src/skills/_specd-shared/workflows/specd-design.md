# specd-design — initial artifacts and item architecture

Read [shared notes](../shared.md) and the [item protocol](../item-work.md).
The main session prepares initial artifacts and develops system alongside code.

1. Read live change status, exact continuation/discovery paths and only relevant
   source sections. Load designing context before hooks/instructions. Obtain
   workspace ownership and follow the hook/transition protocol to enter or
   resume the applicable phase. Inspect drift/review reasons against current
   intent; do not rewrite unaffected content to clear state.
2. Get the relevant `changes artifact-instruction <name> <id>`.
   Use its scope, output paths, template and pre/post rules; request schema or
   outlines only for missing necessary metadata. Register specs before writing
   their deltas and inspect merged results.
   Select ADR authoring only on the user's explicit request; preserve existing
   history and continue ordinary artifact work directly.
3. Write a short proposal containing numbered high-level checkbox items, each
   with a short name and one short purpose sentence. Keep the goal/scope concise.
   These items set the execution order.
4. Prepare requirements in the existing requirement/scenario format. Reuse
   sufficient existing contracts with `no-op` deltas. Then prepare system's
   external interface, relative to the entity being designed (for example a
   CLI, public library API, REST or UI), and the same work-item skeleton. Do not
   complete every item's architecture before starting code. A narrow fix may
   reuse sufficient existing system through `no-op`.
5. Resolve participation before implementation using the item protocol, reusing
   the user's prior choice. Involved batch review occurs after implementation.
6. Self-review initial artifacts against the user's intent and artifact ownership.
   Validate proposal and requirements with correctly scoped commands. Read
   current status and use its readiness/approval route, distinguishing expected
   partial system review flags from actual upstream blockers. System may remain
   incomplete for `ready`/`implementing`. Real CLI spec approval remains human-only.
7. If implementation is authorized, continue with `/specd-implement`: the item
   executor briefly designs one item, obtains independent design review and
   immediately codes it. If only design was requested, deliver the requested
   artifacts and preserve concise continuation at that scope boundary.

Item executors evolve their system sections and implementation together;
proposal and requirements can also be updated through their original authors
as scope or needs evolve. After
all item reviews the main session checks integration, routes corrections to the
original authors and validates the complete system before final verification.
Record special check descriptions in system when explicitly requested by the
user. Conduct ordinary tests and code review during implementation.
