use clap::{ArgAction, CommandFactory, FromArgMatches, Parser};
use serde::Deserialize;
use serde_yaml::Value;
use std::env;
use std::fs;
use std::io;
use std::path::{Component, Path, PathBuf};
use std::process::Command as ProcessCommand;

const SCHEMA_REF: &str = "./schemas/sdd/schema.yaml";

type Result<T> = std::result::Result<T, String>;
type AgentsPlan = Vec<AgentPlan>;

#[derive(Debug, Parser)]
#[command(
    version,
    about = "Bootstrap target projects with this repository's SpecD SDD setup",
    override_usage = "specd-bootstrap [--target <path>] --agent <agent> [--agent <agent> ...]"
)]
struct Args {
    #[arg(long, default_value = ".", value_name = "path")]
    target: PathBuf,

    #[arg(long = "agent", value_name = "agent", required = true, action = ArgAction::Append)]
    agents: Vec<String>,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "camelCase")]
struct AgentPlan {
    agent: String,
    source_skills_dir: PathBuf,
    destination_skills_dir: PathBuf,
}

fn main() -> Result<()> {
    let agent_registry = env::var("SPECD_BOOTSTRAP_AGENT_MANIFESTS")
        .map_err(|_| "SPECD_BOOTSTRAP_AGENT_MANIFESTS is not set".to_string())
        .and_then(|agents| load_agent_registry(&agents));
    let args = parse_args(&agent_registry);
    let schema_root = env::var_os("SPECD_BOOTSTRAP_SCHEMA_ROOT")
        .map(PathBuf::from)
        .ok_or("SPECD_BOOTSTRAP_SCHEMA_ROOT is not set")?;

    validate_schema_root(&schema_root)?;
    let agent_registry = agent_registry?;
    let agent_plans = args
        .agents
        .iter()
        .map(|agent| select_agent_plan(&agent_registry, agent))
        .collect::<Result<Vec<_>>>()?;

    fs::create_dir_all(&args.target).map_err(|err| {
        format!(
            "failed to create target directory {}: {err}",
            args.target.display()
        )
    })?;

    copy_dir_replace(&schema_root, &args.target.join("schemas/sdd"))
        .map_err(|err| format!("failed to materialize schema assets: {err}"))?;

    let specd_yaml = args.target.join("specd.yaml");
    if specd_yaml.exists() {
        update_specd_yaml(&specd_yaml)?;
    } else {
        run_specd_init(&args.target)?;
    }

    for plan in agent_plans {
        let destination_skills_dir = args.target.join(&plan.destination_skills_dir);
        copy_dir_replace(&plan.source_skills_dir, &destination_skills_dir)
            .map_err(|err| format!("failed to install {} skills: {err}", plan.agent))?;
    }

    Ok(())
}

fn parse_args(agent_registry: &Result<AgentsPlan>) -> Args {
    let matches = Args::command()
        .after_help(supported_agents_help(agent_registry))
        .get_matches();

    Args::from_arg_matches(&matches).expect("clap should validate arguments")
}

fn supported_agents_help(agent_registry: &Result<AgentsPlan>) -> String {
    match &agent_registry {
        Ok(registry) => {
            let supported = registry
                .iter()
                .map(|plan| plan.agent.as_str())
                .collect::<Vec<_>>()
                .join(", ");
            format!("Supported agents: {supported}")
        }
        Err(err) => format!("Supported agents: unavailable; {err}"),
    }
}

fn validate_schema_root(schema_root: &Path) -> Result<()> {
    let schema = schema_root.join("schema.yaml");
    let templates = schema_root.join("templates");

    if !schema.is_file() {
        return Err(format!(
            "schema root lacks schema.yaml: {}",
            schema_root.display()
        ));
    }
    if !templates.is_dir() {
        return Err(format!(
            "schema root lacks templates/: {}",
            schema_root.display()
        ));
    }

    Ok(())
}

fn load_agent_registry(manifest_list: &str) -> Result<AgentsPlan> {
    let mut plans = Vec::new();

    for manifest_entry in manifest_list.split(';') {
        let manifest_entry = manifest_entry.trim();
        if manifest_entry.is_empty() {
            continue;
        }

        plans.push(load_agent_manifest(&PathBuf::from(manifest_entry))?);
    }

    if plans.is_empty() {
        return Err("SPECD_BOOTSTRAP_AGENT_MANIFESTS does not list any manifests".to_string());
    }

    Ok(plans)
}

fn load_agent_manifest(manifest: &Path) -> Result<AgentPlan> {
    if !manifest.is_file() {
        return Err(format!("agent manifest not found: {}", manifest.display()));
    }

    let manifest_text = fs::read_to_string(manifest)
        .map_err(|err| format!("failed to read {}: {err}", manifest.display()))?;
    let mut plan = parse_agent_plan(&manifest_text)
        .map_err(|err| format!("failed to parse {}: {err}", manifest.display()))?;
    let manifest_dir = manifest
        .parent()
        .ok_or_else(|| format!("manifest lacks parent directory: {}", manifest.display()))?;
    plan.source_skills_dir = resolve_source_skills_dir(manifest_dir, &plan.source_skills_dir);

    if !plan.source_skills_dir.is_dir() {
        return Err(format!(
            "agent skills directory not found: {}",
            plan.source_skills_dir.display()
        ));
    }

    Ok(plan)
}

fn select_agent_plan(registry: &[AgentPlan], agent: &str) -> Result<AgentPlan> {
    registry
        .iter()
        .find(|plan| plan.agent == agent)
        .cloned()
        .ok_or_else(|| {
            let supported = registry
                .iter()
                .map(|plan| plan.agent.as_str())
                .collect::<Vec<_>>()
                .join(", ");
            format!("unsupported agent target '{agent}'; supported agents: {supported}")
        })
}

fn parse_agent_plan(text: &str) -> Result<AgentPlan> {
    let plan = serde_yaml::from_str::<AgentPlan>(text).map_err(|err| err.to_string())?;

    if plan.agent.is_empty() {
        return Err("agent must not be empty".to_string());
    }
    validate_source_skills_dir(&plan.source_skills_dir)?;
    validate_destination_skills_dir(&plan.destination_skills_dir)?;

    Ok(plan)
}

fn validate_source_skills_dir(path: &Path) -> Result<()> {
    if path.as_os_str().is_empty() {
        return Err("sourceSkillsDir must not be empty".to_string());
    }

    Ok(())
}

fn resolve_source_skills_dir(manifest_dir: &Path, source_skills_dir: &Path) -> PathBuf {
    if source_skills_dir.is_absolute() {
        source_skills_dir.to_path_buf()
    } else {
        manifest_dir.join(source_skills_dir)
    }
}

fn validate_destination_skills_dir(path: &Path) -> Result<()> {
    if path.as_os_str().is_empty() {
        return Err("destinationSkillsDir must not be empty".to_string());
    }
    if path.is_absolute() {
        return Err("destinationSkillsDir must be a relative path".to_string());
    }
    if path
        .components()
        .any(|component| component == Component::ParentDir)
    {
        return Err("destinationSkillsDir must not contain '..'".to_string());
    }

    Ok(())
}

fn update_specd_yaml(path: &Path) -> Result<()> {
    let original = fs::read_to_string(path)
        .map_err(|err| format!("failed to read {}: {err}", path.display()))?;
    let updated = update_specd_yaml_text(&original)?;

    fs::write(path, updated).map_err(|err| format!("failed to write {}: {err}", path.display()))
}

fn update_specd_yaml_text(original: &str) -> Result<String> {
    let mut document = serde_yaml::from_str::<Value>(original)
        .map_err(|err| format!("failed to parse specd.yaml: {err}"))?;
    let mapping = document
        .as_mapping_mut()
        .ok_or("specd.yaml must contain a top-level mapping")?;

    mapping.insert(
        Value::String("schema".to_string()),
        Value::String(SCHEMA_REF.to_string()),
    );

    serde_yaml::to_string(&document).map_err(|err| format!("failed to serialize specd.yaml: {err}"))
}

fn run_specd_init(target: &Path) -> Result<()> {
    let status = ProcessCommand::new("specd")
        .arg("init")
        .arg("--schema")
        .arg(SCHEMA_REF)
        .current_dir(target)
        .status()
        .map_err(|err| format!("failed to execute specd init: {err}"))?;

    if status.success() {
        Ok(())
    } else {
        Err(format!("specd init exited with status {status}"))
    }
}

fn copy_dir_replace(source: &Path, dest: &Path) -> io::Result<()> {
    if dest.exists() {
        fs::remove_dir_all(dest)?;
    }
    fs::create_dir_all(dest)?;
    copy_dir_contents(source, dest)
}

fn copy_dir_contents(source: &Path, dest: &Path) -> io::Result<()> {
    for entry in fs::read_dir(source)? {
        let entry = entry?;
        let file_type = entry.file_type()?;
        let dest_path = dest.join(entry.file_name());

        if file_type.is_dir() {
            fs::create_dir_all(&dest_path)?;
            copy_dir_contents(&entry.path(), &dest_path)?;
        } else if file_type.is_file() {
            fs::copy(entry.path(), dest_path)?;
        } else if file_type.is_symlink() {
            let target = fs::read_link(entry.path())?;
            create_symlink(target, dest_path)?;
        }
    }

    Ok(())
}

#[cfg(unix)]
fn create_symlink<P: AsRef<Path>, Q: AsRef<Path>>(original: P, link: Q) -> io::Result<()> {
    std::os::unix::fs::symlink(original, link)
}

#[cfg(windows)]
fn create_symlink<P: AsRef<Path>, Q: AsRef<Path>>(original: P, link: Q) -> io::Result<()> {
    if original.as_ref().is_dir() {
        std::os::windows::fs::symlink_dir(original, link)
    } else {
        std::os::windows::fs::symlink_file(original, link)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_agent_plan_accepts_exact_schema() {
        let plan = parse_agent_plan(
            r#"
agent: codex
sourceSkillsDir: skills
destinationSkillsDir: .codex/skills
"#,
        )
        .expect("manifest should parse");

        assert_eq!(plan.agent, "codex");
        assert_eq!(plan.source_skills_dir, PathBuf::from("skills"));
        assert_eq!(plan.destination_skills_dir, PathBuf::from(".codex/skills"));
    }

    #[test]
    fn parse_agent_plan_rejects_unknown_fields() {
        let err = parse_agent_plan(
            r#"
agent: codex
sourceSkillsDir: skills
destinationSkillsDir: .codex/skills
extra: nope
"#,
        )
        .expect_err("unknown fields should be rejected");

        assert!(err.contains("unknown field"));
    }

    #[test]
    fn parse_agent_plan_allows_parent_components_in_source_skills_dir() {
        let plan = parse_agent_plan(
            r#"
agent: codex
sourceSkillsDir: ../skills
destinationSkillsDir: .codex/skills
"#,
        )
        .expect("sourceSkillsDir should allow paths relative to the manifest");

        assert_eq!(plan.source_skills_dir, PathBuf::from("../skills"));
    }

    #[test]
    fn parse_agent_plan_allows_absolute_source_skills_dir() {
        let plan = parse_agent_plan(
            r#"
agent: codex
sourceSkillsDir: /nix/store/source/skills
destinationSkillsDir: .codex/skills
"#,
        )
        .expect("sourceSkillsDir should allow absolute paths");

        assert_eq!(
            plan.source_skills_dir,
            PathBuf::from("/nix/store/source/skills")
        );
    }

    #[test]
    fn resolve_source_skills_dir_keeps_absolute_paths() {
        assert_eq!(
            resolve_source_skills_dir(
                Path::new("/nix/store/manifest-root"),
                Path::new("/nix/store/source/skills")
            ),
            PathBuf::from("/nix/store/source/skills")
        );
    }

    #[test]
    fn resolve_source_skills_dir_resolves_relative_paths_from_manifest_dir() {
        assert_eq!(
            resolve_source_skills_dir(
                Path::new("/nix/store/manifest-root"),
                Path::new("../skills")
            ),
            PathBuf::from("/nix/store/manifest-root/../skills")
        );
    }

    #[test]
    fn parse_agent_plan_rejects_unsafe_destination_skills_dir() {
        let err = parse_agent_plan(
            r#"
agent: codex
sourceSkillsDir: skills
destinationSkillsDir: ../.codex/skills
"#,
        )
        .expect_err("parent target path should be rejected");

        assert!(err.contains("destinationSkillsDir"));
    }

    #[test]
    fn update_specd_yaml_replaces_schema_and_keeps_other_fields() {
        let updated = update_specd_yaml_text(
            r#"
schema: ./old/schema.yaml
workspaces:
  - name: default
    path: docs/specs
metadata:
  keep: true
"#,
        )
        .expect("specd.yaml should update");
        let document = serde_yaml::from_str::<Value>(&updated).expect("updated yaml should parse");
        let mapping = document
            .as_mapping()
            .expect("document should stay a mapping");

        assert_eq!(
            mapping.get(Value::String("schema".to_string())),
            Some(&Value::String(SCHEMA_REF.to_string()))
        );
        assert_eq!(
            mapping
                .get(Value::String("metadata".to_string()))
                .and_then(Value::as_mapping)
                .and_then(|metadata| metadata.get(Value::String("keep".to_string())))
                .and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            mapping
                .get(Value::String("workspaces".to_string()))
                .and_then(Value::as_sequence)
                .and_then(|workspaces| workspaces.first())
                .and_then(Value::as_mapping)
                .and_then(|workspace| workspace.get(Value::String("path".to_string())))
                .and_then(Value::as_str),
            Some("docs/specs")
        );
    }

    #[test]
    fn update_specd_yaml_adds_schema_when_missing() {
        let updated = update_specd_yaml_text(
            r#"
workspaces:
  - name: default
    path: docs/specs
"#,
        )
        .expect("specd.yaml should update");
        let document = serde_yaml::from_str::<Value>(&updated).expect("updated yaml should parse");
        let mapping = document
            .as_mapping()
            .expect("document should stay a mapping");

        assert_eq!(
            mapping.get(Value::String("schema".to_string())),
            Some(&Value::String(SCHEMA_REF.to_string()))
        );
        assert!(mapping.contains_key(Value::String("workspaces".to_string())));
    }

    #[test]
    fn supported_agents_help_lists_registry_names() {
        let registry = Ok(vec![
            AgentPlan {
                agent: "codex".to_string(),
                source_skills_dir: PathBuf::from("codex/skills"),
                destination_skills_dir: PathBuf::from(".codex/skills"),
            },
            AgentPlan {
                agent: "opencode".to_string(),
                source_skills_dir: PathBuf::from("opencode/skills"),
                destination_skills_dir: PathBuf::from(".opencode/skills"),
            },
        ]);

        assert_eq!(
            supported_agents_help(&registry),
            "Supported agents: codex, opencode"
        );
    }
}
