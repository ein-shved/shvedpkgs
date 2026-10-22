# specd — start or resume

Read [shared notes](../shared.md). Work directly from the user's goal and live
state; this entry point can continue into the authorized lifecycle work.

1. Load project context and enough project status to identify workspaces and
   active changes. Reuse an equivalent fresh result.
2. If a change is named or clearly identified by the conversation, read its
   `changes status <name> --format text`; inspect blockers and next action.
   Otherwise select the clearly intended active change, or ask only when the
   choice is ambiguous. A new goal routes to `/specd-new`.
3. Load binding context before hooks, instructions or writes. Route to
   `/specd-design`, `/specd-implement` or `/specd-verify` according to live state
   and the user's scope. As shared notes explain, expected partial system work
   does not block implementation; unresolved upstream drift must be reviewed.
4. Continue through authorized phases, observing the explicit post-proposal
   involvement choice and latest level's user checkpoints. Present results for
   user review after independent agent review and corrections. A request for
   status/orientation only remains read-only. Human-only CLI approvals and
   substantive unresolved decisions still require the user.

Return concise progress or the completed result. Default completion is ready
for closure; use `/specd-archive` only when archiving is requested.
