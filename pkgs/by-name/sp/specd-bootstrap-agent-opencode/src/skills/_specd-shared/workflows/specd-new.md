# specd-new — discover and create

Read [shared notes](../shared.md). The main session owns discovery and creation.

1. Load `specd project context --format text` and workspace status needed for
   ownership and code roots. Reuse clear goals and constraints already supplied;
   investigate only missing facts. Read relevant spec summaries/full contracts
   through the CLI and affected code at its actual root. Optional research
   workers return compact verified context.
2. Choose a short change name, one-line purpose and affected owning specs.
   Existing covered behavior still attaches its spec; uncovered behavior needs
   an owning spec. Exclude readOnly write targets. Ask only for material scope
   choices that cannot be inferred from the user's request.
3. When creation is within the requested work, run
   `specd changes create <name> --spec <specId> --description <description> --format toon`
   (omit `--spec` if scope is not known yet). If it already exists, inspect that
   change's live state and resume it. Resolve overlap warnings as shared notes
   require. Obtain the real `changePath` from the response/status.
4. Load the change's drafting context before drafting hooks/instructions.
   Run drafting entry hooks and follow their instructions. Register known real
   spec dependencies when needed. Save only useful verified discovery, decisions
   and open questions in exact change-local `.specd-exploration.md`/`.context`;
   these notes do not replace artifacts.
5. Complete drafting hooks and continue to `/specd-design` when design or full
   implementation is authorized. If the user requested creation/discovery only,
   return the created change and concise continuation at that boundary.

Create directly when the user's request authorizes it. Follow the
[item protocol](../item-work.md) for later authorship and review.
