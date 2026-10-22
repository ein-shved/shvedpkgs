# Proposal: tighten-sdd-artifact-boundaries

**Category: large architectural development.** Several independent decisions
reshape artifact ownership, agent coordination, and context boundaries.

**Participation: involved.**

Make SDD artifacts short and sufficient, and organize design work so each
decision receives the context and review it needs.

| # | Topic | Owning artifact |
| --- | --- | --- |
| 1 | Design needs | requirements |
| 2 | Compact proposal | system |
| 3 | Artifact boundaries | system |
| 4 | Agent coordination | system |
| 5 | Session boundaries | system |
| 6 | Subsystem design | system |
| 7 | Technical evidence | validate |
| 8 | Coordination choice | adrs |
| 9 | Implementation transition | plan |

1. **Design needs.** Add needs for proportionate design contexts and an
   explicit choice of user involvement; retain existing needs.
2. **Compact proposal.** Start with category and a very short problem statement,
   discuss the numbered allocation here, and follow it with at most two
   sentences per item; supporting material lives in change-local `.context`.
3. **Artifact boundaries.** Give each definition one owner, preserve useful
   contracts while removing repetition, and distinguish automated checks from
   manual obligations.
4. **Agent coordination.** Offer involved or delegated design during proposal;
   in delegated mode a coordinator makes routine design decisions and accepts
   artifacts while managers, executors, and arbiters work in scoped groups.
5. **Session boundaries.** Small changes may keep one group through plan;
   large changes use fresh groups per step, opened by the user in involved
   mode or launched by the coordinator in delegated mode.
6. **Subsystem design.** First establish the system overview and subsystem
   skeleton; then give each subsystem to a fresh group and reconcile affected
   interfaces and earlier sections.
7. **Technical evidence.** Check the actual workflow, review ordering, context
   handoff, artifact quality, and delivery using isolated probes.
8. **Coordination choice.** Record why skills coordinate agents, schema delivers
   authoring instructions, artifact rules own content semantics, and SpecD
   tracks lifecycle state.
9. **Implementation transition.** Align schema, templates, skills, and project
   guidance while preserving completed work. Keep artifact rules focused on
   tool-independent content contracts, with production workflow in its
   operational resources.

**Affected spec:** `default:000-sdd-process`; no new specs or dependencies.
Supporting evidence, implementation boundaries, and interpretation notes:
[change context](.context).
