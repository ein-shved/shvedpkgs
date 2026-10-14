# Proposal: project-aware-nixos-tests

**Category: large architectural development.** Runner integration, the shared
node environment and guest package assembly require separate design decisions.

**Participation: involved.**

NixOS test authors currently have to reconstruct the project's module environment
to exercise its reusable capabilities. Provide that environment through the test
runner while keeping nodes focused and existing packages and tests usable.

| # | Topic | Owning artifact |
| --- | --- | --- |
| 1 | Project capabilities in tests | requirements |
| 2 | Focused test nodes | requirements |
| 3 | Existing package and test compatibility | requirements |
| 4 | Runner entry point | system |
| 5 | Shared node environment | system |
| 6 | Conformance evidence | validate |
| 7 | Implementation transition | plan |

1. Test authors need to exercise reusable project capabilities without assembling
   their shared module environment anew for each test, using the project's own
   definitions.
2. Making capabilities available must leave unrelated functionality inactive;
   each node selects the behavior and supplies the inputs relevant to its test.
3. Existing packages and package tests must remain usable, including tests that
   use only the upstream NixOS environment.
4. Prefer extending the existing `testers.runNixOSTest` when compatibility can be
   preserved; otherwise use a separate entry point based on the upstream runner.
   Its API and composition with upstream test interfaces belong in system design.
5. Define the reusable module environment, evaluation arguments and guest package
   assembly using current project contracts, without importing `config/`, concrete
   host policy or validation stubs automatically.
6. Define checks and evidence for capability use, minimal-node isolation and
   compatibility, distinguishing evaluation, builds and VM execution. Preserve
   the existing validation-configuration and private-value-stub contracts.
7. Plan the implementation and its validation against the accepted runner design,
   consuming the existing optional-module and primary-user/Home Manager contracts.

**Affected specs:** `default:003-testing-infrastructure`.
Supporting context: [.context](.context).
