{
  gitMinimal,
  opencode,
  runCommand,
  specd,
  specd-bootstrap,
  specd-bootstrap-sdd-schema,
  testers,
  checkOpenCodeDiscovery ? true,
}:

let
  customAgent = runCommand "specd-bootstrap-agent-custom-test" { } ''
    mkdir -p "$out/skills"
    cat > "$out/manifest.yaml" <<'EOF'
agent: custom-test
sourceSkillsDir: skills
destinationSkillsDir: .custom-agent/skills
EOF
    printf 'custom payload\n' > "$out/skills/payload.txt"
  '';
in
testers.runNixOSTest {
  name = "specd-bootstrap";

  nodes.machine =
    { ... }:
    {
      environment.systemPackages = [
        gitMinimal
        opencode
        specd
        specd-bootstrap
      ];
    };

  testScript = ''
    import json
    import shlex

    start_all()

    def write_file(path, content):
      machine.succeed(f"printf %s {shlex.quote(content)} > {shlex.quote(path)}")

    schema_root = "${specd-bootstrap-sdd-schema}/share/specd-bootstrap/schemas/sdd"
    custom_agent_manifests = "${customAgent}/manifest.yaml"

    machine.succeed("specd-bootstrap --help | grep -F 'Usage: specd-bootstrap [--target <path>] --agent <agent> [--agent <agent> ...]'")
    machine.succeed("specd-bootstrap --help | grep -F 'Supported agents:' | grep -F 'codex' | grep -F 'opencode' | grep -F 'kilocode'")
    machine.succeed(f"SPECD_BOOTSTRAP_AGENT_MANIFESTS='{custom_agent_manifests}' specd-bootstrap --help | grep -F 'Supported agents: custom-test'")
    machine.fail(f"SPECD_BOOTSTRAP_AGENT_MANIFESTS='{custom_agent_manifests}' specd-bootstrap --help | grep -F 'codex'")
    machine.succeed("test -f ${specd-bootstrap-sdd-schema}/share/specd-bootstrap/schemas/sdd/schema.yaml")
    machine.succeed("test -d ${specd-bootstrap-sdd-schema}/share/specd-bootstrap/schemas/sdd/templates")
    machine.succeed("diff -r ${../../schemas/sdd} ${specd-bootstrap-sdd-schema}/share/specd-bootstrap/schemas/sdd")

    machine.succeed("mkdir -p /tmp/specd-bootstrap-new")
    machine.succeed("cd /tmp/specd-bootstrap-new && git init")
    machine.succeed("cd /tmp/specd-bootstrap-new && env -u SPECD_BOOTSTRAP_SCHEMA_ROOT -u SPECD_BOOTSTRAP_AGENT_MANIFESTS specd-bootstrap --agent codex")
    machine.succeed("test -f /tmp/specd-bootstrap-new/specd.yaml")
    machine.succeed("test -f /tmp/specd-bootstrap-new/schemas/sdd/schema.yaml")
    machine.succeed("test -d /tmp/specd-bootstrap-new/schemas/sdd/templates")
    machine.succeed("test -f /tmp/specd-bootstrap-new/.codex/skills/specd/SKILL.md")
    machine.succeed("grep -F 'schema: ./schemas/sdd/schema.yaml' /tmp/specd-bootstrap-new/specd.yaml")
    machine.succeed("cd /tmp/specd-bootstrap-new && specd changes list --format text")

    # Architectural work can start before later design is ready. Neither branch
    # needs proposal checkboxes; Update may reuse unchanged SDD contracts.
    workflow_project = "/tmp/specd-bootstrap-new"
    machine.succeed(f"git -C {workflow_project} config user.name 'SpecD Test'")
    machine.succeed(f"git -C {workflow_project} config user.email 'specd-test@example.invalid'")

    def changes(command):
      return json.loads(machine.succeed(f"cd {workflow_project} && specd changes {command} --format json"))

    machine.succeed(f"mkdir -p {workflow_project}/specs/demo")
    write_file(f"{workflow_project}/specs/demo/requirements.md", "# Requirements\n")
    write_file(f"{workflow_project}/specs/demo/system.md", "# System Specification\n")
    change_path = changes("create incremental --spec default:demo")["changePath"]
    delta_path = f"{change_path}/deltas/default/demo"
    machine.succeed(f"mkdir -p {delta_path}")
    proposal = (
      "# Proposal: incremental\n\n**Type:** Architectural change\n\nImplement readiness reporting.\n\n"
      "| # | Topic | Artifact |\n| - | ----- | -------- |\n| 1 | Readiness | system |\n\n"
      "1. Describe readiness reporting.\n\n## Proposed system\n\n1. Readiness.\n"
    )
    write_file(f"{change_path}/proposal.md", proposal)
    write_file(f"{delta_path}/requirements.md.delta.yaml", (
      "- op: added\n  position:\n    parent:\n      type: section\n      matches: '^Requirements$'\n  content: |\n"
      "    ## REQ-001: Report readiness\n\n    Users can request readiness.\n\n"
      "    ### Scenario: Readiness request\n\n    - WHEN readiness is requested\n"
      "    - THEN the service returns its current state\n"
    ))
    system = (
      "- op: added\n  position:\n    parent:\n      type: section\n      matches: '^System Specification$'\n  content: |\n"
      "    ## External Interface\n\n    The CLI reports readiness.\n"
      "    [REQ-001](requirements.md#req-001-report-readiness).\n\n"
      "    ## Readiness\n\n    Pending.\n"
    )
    write_file(f"{delta_path}/system.md.delta.yaml", system)
    changes("transition incremental designing")
    assert changes("validate incremental --artifact proposal")["passed"]
    assert changes("validate incremental default:demo --artifact requirements")["passed"]
    changes("transition incremental ready")
    changes("transition incremental implementing")
    status = changes("status incremental")
    assert status["state"] == "implementing"
    assert next(a for a in status["artifacts"] if a["type"] == "system")["effectiveStatus"] == "in-progress"

    write_file(f"{delta_path}/system.md.delta.yaml", system.replace(
      "Pending.", "The readiness handler returns the current service state."
    ))
    assert changes("validate incremental default:demo --artifact system")["passed"]
    changes("transition incremental verifying")
    status = changes("status incremental")
    assert status["state"] == "verifying"
    assert next(a for a in status["artifacts"] if a["type"] == "proposal")["effectiveStatus"] == "complete"

    for step in ["done", "archivable"]:
      changes(f"transition incremental {step}")
    archive_result = changes("archive incremental")["archivePath"]
    archive_path = machine.succeed(f"cd {workflow_project} && realpath {shlex.quote(archive_result)}").strip()
    # Agent post-instructions remove only the successful archive's proposal.
    machine.succeed(f"test -f {shlex.quote(archive_path)}/proposal.md")
    machine.succeed(f"rm -- {shlex.quote(archive_path)}/proposal.md")
    machine.fail(f"test -e {shlex.quote(archive_path)}/proposal.md")
    machine.succeed(f"test -d {shlex.quote(archive_path)}/deltas")

    original_requirements = machine.succeed(f"cat {workflow_project}/specs/demo/requirements.md")
    original_system = machine.succeed(f"cat {workflow_project}/specs/demo/system.md")
    update_path = changes("create localized --spec default:demo")["changePath"]
    machine.succeed(f"mkdir -p {update_path}/deltas/default/demo")
    write_file(f"{update_path}/proposal.md", (
      "# Proposal: localized\n\n**Type:** Update\n\nCorrect readiness formatting.\n\n"
      "| # | Topic | Artifact |\n| - | ----- | -------- |\n| 1 | Output | code |\n\n"
      "1. Correct readiness output without changing its contract.\n\n"
      "**Affected specs:** default:demo\n"
    ))
    for artifact in ["requirements", "system"]:
      write_file(f"{update_path}/deltas/default/demo/{artifact}.md.delta.yaml", "- op: no-op\n")
    changes("transition localized designing")
    assert changes("validate localized --artifact proposal")["passed"]
    assert changes("validate localized default:demo --artifact requirements")["passed"]
    for step in ["ready", "implementing"]:
      changes(f"transition localized {step}")
    assert changes("validate localized default:demo --artifact system")["passed"]
    for step in ["verifying", "done", "archivable"]:
      changes(f"transition localized {step}")
    changes("archive localized")
    assert machine.succeed(f"cat {workflow_project}/specs/demo/requirements.md") == original_requirements
    assert machine.succeed(f"cat {workflow_project}/specs/demo/system.md") == original_system

    machine.succeed("mkdir -p /tmp/specd-bootstrap-existing")
    machine.succeed("cd /tmp/specd-bootstrap-existing && git init")
    machine.succeed("printf '%s\n' 'schema: ./old/schema.yaml' 'workspaces:' '  - name: default' '    path: docs/specs' > /tmp/specd-bootstrap-existing/specd.yaml")
    machine.succeed("specd-bootstrap --target /tmp/specd-bootstrap-existing --agent codex")
    machine.succeed("grep -F 'schema: ./schemas/sdd/schema.yaml' /tmp/specd-bootstrap-existing/specd.yaml")
    machine.succeed("grep -F 'path: docs/specs' /tmp/specd-bootstrap-existing/specd.yaml")
    machine.succeed("test -f /tmp/specd-bootstrap-existing/.codex/skills/specd/SKILL.md")

    machine.succeed("mkdir -p /tmp/specd-bootstrap-multi")
    machine.succeed("cd /tmp/specd-bootstrap-multi && git init")
    machine.succeed("specd-bootstrap --target /tmp/specd-bootstrap-multi --agent codex --agent kilocode")
    machine.succeed("test -f /tmp/specd-bootstrap-multi/.codex/skills/specd-new/SKILL.md")
    machine.succeed("test -f /tmp/specd-bootstrap-multi/.kilocode/skills/specd-new/SKILL.md")
    machine.succeed("grep -F '$specd-design' /tmp/specd-bootstrap-multi/.codex/skills/_specd-shared/workflows/specd-new.md")
    machine.succeed("grep -F '/specd-design' /tmp/specd-bootstrap-multi/.kilocode/skills/_specd-shared/workflows/specd-new.md")

    machine.succeed("mkdir -p /tmp/specd-bootstrap-opencode")
    machine.succeed("cd /tmp/specd-bootstrap-opencode && git init")
    machine.succeed("specd-bootstrap --target /tmp/specd-bootstrap-opencode --agent opencode")
    machine.succeed("test -f /tmp/specd-bootstrap-opencode/.opencode/skills/specd/SKILL.md")
    machine.succeed("grep -F '/specd-new' /tmp/specd-bootstrap-opencode/.opencode/skills/_specd-shared/workflows/specd.md")
    if ${if checkOpenCodeDiscovery then "True" else "False"}:
      machine.succeed("cd /tmp/specd-bootstrap-opencode && opencode debug skill | grep -F '\"name\": \"specd-new\"'")

    agent_sources = {
      "codex": "${../../pkgs/by-name/sp/specd-bootstrap-agent-codex/src/skills}",
      "opencode": "${../../pkgs/by-name/sp/specd-bootstrap-agent-opencode/src/skills}",
      "kilocode": "${../../pkgs/by-name/sp/specd-bootstrap-agent-kilocode/src/skills}",
    }
    workflow_skills = [
      "specd", "specd-new", "specd-design", "specd-implement",
      "specd-verify", "specd-archive", "specd-compliance", "specd-metadata",
    ]
    for agent, source in agent_sources.items():
      project = f"/tmp/specd-workflow-{agent}"
      installed = f"{project}/.{agent}/skills"
      machine.succeed(f"mkdir -p {project} && cd {project} && git init")
      machine.succeed(f"specd-bootstrap --target {project} --agent {agent}")
      machine.succeed(f"diff -r {source} {installed}")
      machine.succeed(f"diff -r {schema_root} {project}/schemas/sdd")
      for resource in ["shared.md", "item-work.md", "process-development.md"]:
        machine.succeed(f"test -s {installed}/_specd-shared/{resource}")
      for skill in workflow_skills:
        machine.succeed(f"test -s {installed}/{skill}/SKILL.md")
        machine.succeed(f"test -s {installed}/_specd-shared/workflows/{skill}.md")

      # Updating an older installation removes retired resources as well as
      # replacing changed files, and preserves the project's workspaces.
      for resource in ["manager.md", "coordinator.md", "arbiter.md"]:
        machine.succeed(f"printf obsolete > {installed}/_specd-shared/{resource}")
      for template in ["plan.md", "validate.md"]:
        machine.succeed(f"printf obsolete > {project}/schemas/sdd/templates/{template}")
      machine.succeed(f"printf stale > {installed}/_specd-shared/workflows/specd-design.md")
      machine.succeed(f"printf stale > {installed}/specd-design/SKILL.md")
      machine.succeed(f"printf stale > {project}/schemas/sdd/templates/proposal.md")
      machine.succeed(f"printf '%s\n' 'schema: ./old/schema.yaml' 'workspaces:' '  - name: default' '    path: docs/specs' > {project}/specd.yaml")
      machine.succeed(f"specd-bootstrap --target {project} --agent {agent}")
      for resource in ["manager.md", "coordinator.md", "arbiter.md"]:
        machine.fail(f"test -e {installed}/_specd-shared/{resource}")
      for template in ["plan.md", "validate.md"]:
        machine.fail(f"test -e {project}/schemas/sdd/templates/{template}")
      machine.succeed(f"diff -r {source} {installed}")
      machine.succeed(f"diff -r {schema_root} {project}/schemas/sdd")
      machine.succeed(f"grep -F 'path: docs/specs' {project}/specd.yaml")

    machine.succeed("mkdir -p /tmp/specd-bootstrap-custom")
    machine.succeed("cd /tmp/specd-bootstrap-custom && git init")
    machine.succeed(f"cd /tmp/specd-bootstrap-custom && SPECD_BOOTSTRAP_SCHEMA_ROOT={schema_root} SPECD_BOOTSTRAP_AGENT_MANIFESTS='{custom_agent_manifests}' specd-bootstrap --agent custom-test")
    machine.succeed("grep -F 'custom payload' /tmp/specd-bootstrap-custom/.custom-agent/skills/payload.txt")

    machine.fail("specd-bootstrap --target /tmp/specd-bootstrap-unsupported --agent unsupported-agent")
    machine.fail("test -e /tmp/specd-bootstrap-unsupported/specd.yaml")

    # TODO: Add kilocode non-agentic skill discovery when a suitable CLI package
    # and stable debug subcommand are available in this package set.
    # TODO: Add Codex skill discovery if Codex exposes a local non-agentic
    # inspection command comparable to `opencode debug skill`.
  '';
}
