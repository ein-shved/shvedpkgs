# specd-new — create and review the proposal

Read [shared notes](../shared.md) and the [item protocol](../item-work.md).
The main session owns discovery, creation and the initial proposal gate.

1. Load `specd project context --format text` and workspace status needed for
   ownership and code roots. Reuse supplied goals and constraints; investigate
   missing facts. Read relevant spec summaries/full contracts through the CLI
   and affected code at its actual root. Optional research workers return
   compact verified context.
2. Choose a short change name, one-line purpose and affected owning specs.
   Existing covered behavior still attaches its spec; uncovered behavior needs
   an owning spec. Exclude readOnly write targets. Ask only for material scope
   choices that cannot be inferred from the user's request.
3. When creation is authorized, run
   `specd changes create <name> --spec <specId> --description <description> --format toon`
   (omit `--spec` if scope is not known yet). If it exists, inspect that change's
   live state and resume it. Resolve overlap warnings as shared notes require.
   Obtain the real `changePath` from response/status.
4. Load drafting context before drafting hooks/instructions. Run entry hooks,
   register known real spec dependencies when needed, and save useful verified
   discovery, decisions and open questions in exact change-local
   `.specd-exploration.md`/`.context`. Complete drafting hooks.
5. Continue directly into `$specd-design` to prepare the short proposal, including
   concrete artifact allocation and high-level work items. Creation includes
   this proposal. Obtain independent proposal review and corrections before
   presenting it for user review; resolve that review through its original author.
6. After user proposal review finishes, ask the mandatory involvement question
   from the item protocol and wait. Earlier preferences do not replace this
   question for the new change. Requirements/system follow the recorded answer.
   For a resumed unchanged reviewed proposal, reuse its recorded answered gate.
7. Continue authorized work directly after the answer. A creation-only request
   ends with the reviewed proposal and recorded choice; broader authorization
   continues through the chosen involvement checkpoints.
