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

      system.stateVersion = "26.05";
    };

  testScript = ''
    start_all()

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
    machine.succeed("grep -F '$specd-design' /tmp/specd-bootstrap-multi/.codex/skills/specd-new/SKILL.md")
    machine.succeed("grep -F '/specd-design' /tmp/specd-bootstrap-multi/.kilocode/skills/specd-new/SKILL.md")

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
      for resource in ["shared.md", "manager.md", "arbiter.md", "coordinator.md"]:
        machine.succeed(f"test -s {installed}/_specd-shared/{resource}")
      for skill in workflow_skills:
        machine.succeed(f"test -s {installed}/{skill}/SKILL.md")
        machine.succeed(f"test -s {installed}/_specd-shared/workflows/{skill}.md")

      # An update replaces stale entry, role, procedure and schema content while
      # preserving the target project's workspace configuration.
      machine.succeed(f"printf stale > {installed}/_specd-shared/manager.md")
      machine.succeed(f"printf stale > {installed}/_specd-shared/workflows/specd-design.md")
      machine.succeed(f"printf stale > {installed}/specd-design/SKILL.md")
      machine.succeed(f"printf stale > {project}/schemas/sdd/templates/proposal.md")
      machine.succeed(f"printf '%s\n' 'schema: ./old/schema.yaml' 'workspaces:' '  - name: default' '    path: docs/specs' > {project}/specd.yaml")
      machine.succeed(f"specd-bootstrap --target {project} --agent {agent}")
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
