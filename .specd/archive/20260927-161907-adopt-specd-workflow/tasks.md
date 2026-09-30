# Tasks: adopt-specd-workflow

## 1. Project setup

- [x] 1.1 Initialize SpecD configuration
      `specd.yaml` — configure `@specd/schema-std`, the `default` workspace,
      and filesystem storage for changes, drafts, discarded changes, and
      archive.
      Approach: use `specd init` and keep the generated paths.
      (Req: SpecD provides machine-readable workflow state)

- [x] 1.2 Add baseline development-host tooling spec
      `specs/development-host-tooling/{spec.md,verify.md}` — mirror the
      current development tooling contract for future SpecD-guided changes.
      Approach: write a steady-state SpecD spec derived from
      `spec/requirements.md` and `spec/system.md`.
      (Req: SpecD specs may mirror current SDD contracts)

## 2. Adoption change

- [x] 2.1 Add SpecD SDD integration spec artifacts
      `.specd/changes/.../specs/default/specd-sdd-integration/` — define the
      boundary between SpecD and the existing SDD process.
      Approach: create `spec.md` and `verify.md` using the standard schema
      headings and scenario format.
      (Req: Existing SDD process remains authoritative, Requirement validation
      may use scenario-style checks)

- [x] 2.2 Add proposal and design artifacts
      `.specd/changes/.../{proposal.md,design.md}` — record why the layer is
      being added and how it is structured.
      Approach: keep the content focused on workflow metadata and avoid Nix
      implementation changes.
      (Req: Changes that modify behavior pass through SpecD artifacts)

## 3. Validation

- [x] 3.1 Validate SpecD state
      SpecD CLI — confirm specs, change artifacts, and project status are
      readable and structurally valid.
      Approach: run `specd specs validate`, `specd changes validate`, and
      `specd project status --context --graph --format toon`.
      (Req: SpecD provides machine-readable workflow state)
