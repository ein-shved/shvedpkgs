# specd-new — create and prepare the proposal

Read [shared notes](../shared.md) and [item protocol](../item-work.md).
The main agent owns change creation and initial artifacts, avoiding details.

1. Load project context and fresh status for workspace ownership/code roots.
   Read relevant SDD summaries/full contracts through the CLI. Use the task and
   those artifacts for classification. Delegate any missing research context;
   the main agent does not inspect code or browse during proposal preparation.
2. Choose a short name, purpose and affected owning specs. Attach existing
   owning specs even if needs remain unchanged; exclude readOnly write targets.
   Ask only for material scope choices not resolved by available task context.
3. Run `specd changes create <name> --spec <specId> --description <description>
   --format toon` when creation is authorized, or resume the existing change.
   Obtain the real changePath and handle overlap warnings as shared notes say.
4. Load actual drafting context before hooks/instructions. Save useful research
   in change-local .specd-exploration.md and continuation in .context. Keep these
   outside the artifact graph. Complete actual phase hooks/instructions.
5. Continue into `$specd-design` to write the short proposal in the live format.
   After writing it obtain the explicit involvement choice unless already
   maximally explicitly supplied. Never infer it. Apply its review boundaries,
   with independent artifact arbitration before user review.
6. Continue within authorized scope after the choice. Reuse the recorded choice
   on resume and honor changes at any time. A creation-only request ends with
   the proposal and involvement handling; broader work continues by that level.
