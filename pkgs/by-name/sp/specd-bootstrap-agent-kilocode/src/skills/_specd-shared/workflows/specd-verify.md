# specd-verify — verify the completed change

Read [shared notes](../shared.md). Verification compares actual implementation
with merged requirements and system, including any explicitly requested checks.

1. Read status and load verifying context before hooks/instructions. Confirm
   the affected work passed its reviews/checks and the complete system was
   structurally validated. Inspect review-required final contracts before
   progress; route corrections to their original executors.
2. Enter/resume verifying through the shared hook/transition protocol. Load only
   needed scenarios, constraints and dependencies. Reuse fresh full merged
   content; otherwise use `changes spec-preview <name> <specId> --artifact <id>`.
   Raw deltas alone are insufficient.
3. Evaluate every affected requirement scenario against the implementation.
   Run all applicable project, change-artifact, SpecD and user checks; these
   sources accumulate obligations. Inspect results and identify coverage limits.
   Process changes require retained blind scenarios from
   [process development](../process-development.md), with root links in results.
   Reuse valid item evidence rather than rerunning checks without changed inputs
   or an unresolved concern. Record actual pass/fail evidence outside normative
   artifacts; do not invent successful verification.
4. Send defects/questions to the original item executor. Implementation-only
   repairs return through implementing as needed, followed by relevant checks
   and code review. Routine artifact alignment stays within authorized work;
   significant inconsistencies need the user's decision. Revalidate changed
   final contracts before resuming verification.
5. When scenarios and required checks pass, complete verifying hooks and follow
   live transitions through done/signoff to archivable, applying hooks/context
   at the actual states entered. Never run `changes approve`: present required
   human spec/signoff approval commands and keep continuation while waiting.
6. Report completed work, tests and material limits. Honor the recorded
   involvement level and present results for user review only after applicable
   agent reviews and corrections clear. Route feedback to original executors.
   Fully delegated work finishes ready for closure. Do not archive unless requested; if archiving is
   already authorized, continue to `/specd-archive` without asking again.
