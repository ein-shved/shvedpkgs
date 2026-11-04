# specd-design — initial artifacts and architecture

Read [shared notes](../shared.md) and [item protocol](../item-work.md).

1. Read live state and exact continuation/discovery sources. Load designing
   context before hooks/instructions and obtain workspace ownership. Follow
   actual CLI lifecycle diagnostics while respecting authorized scope.
2. Get `changes artifact-instruction <name> <id>` and follow live scope, output,
   template and pre/post rules. Register affected specs before writing deltas;
   inspect merged results. ADR work requires explicit user request.
3. Write concise proposal intent, change type, compact allocation table and
   matching one-sentence explanations. For architectural change add the short
   system outline serving as implementation plan; Update has no required plan.
   Outline points are solution parts; ordinary tests/docs belong with their
   implementation. Asking for tests alone does not request system check prose.
   The main agent uses SDD artifacts only and delegates missing research context.
4. After writing proposal obtain the explicit involvement choice, unless already
   maximally explicitly supplied. Record it in continuation; do not guess or
   repeat on resume. Apply changes at any time. Before user review an independent
   nonauthor arbiter checks artifacts and the original author resolves findings.
5. Full involvement presents each successive artifact for approval before
   continuing. Partial involvement independently prepares initial requirements
   and API/skeleton for architectural change, or necessary Update design edits,
   then obtains user review before independent implementation. Full delegation
   prepares artifacts independently. Reuse sufficient contracts with no-op
   deltas; Update may require no changes to other SDD artifacts.
6. The main agent may update Update design only when context already suffices.
   Otherwise a research subagent updates design and may implement. Architectural
   detailed design belongs to each plan point's executor. Review new or updated
   design through the same independent arbiters who will later review code.
7. Validate proposal/requirements for native readiness. System may remain partial
   while architectural items develop; an initial structural validation does not
   freeze the design. Continue authorized `/specd-implement` work after required
   reviews. A design-only request stops at its explicit boundary.

Use short sections, lists and paragraphs; omit incidental implementation detail.
Original authors handle corrections. Serious inconsistencies, including required
hacks/workarounds, stop work for the user's decision in every involvement mode.
