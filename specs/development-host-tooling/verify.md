# Verification: Development Host Tooling

## Requirements

### Requirement: Development hosts expose required workflow tools

#### Scenario: Development host receives workflow tools

- GIVEN a host configuration has `hardware.development = true`
- WHEN its evaluated `config.environment.systemPackages` is inspected
- THEN the package list includes `codex`
- AND the package list includes `specd`

#### Scenario: SpecD package exposes the genuine CLI

- GIVEN the repository package set exposes `pkgs.specd`
- WHEN the package command is invoked with a valid inspection argument
- THEN the command reports behavior consistent with the genuine SpecD CLI

### Requirement: Non-development hosts are not required to expose development tooling

#### Scenario: Non-development host does not receive development bucket tools

- GIVEN a host configuration has `hardware.development = false`
- WHEN its evaluated `config.environment.systemPackages` is inspected
- THEN absence of `codex` does not violate this spec
- AND absence of `specd` does not violate this spec

### Requirement: Tooling selection belongs to development host configuration

#### Scenario: Package definitions stay host-policy free

- GIVEN a package definition under `pkgs`
- WHEN it is evaluated as a package-set member
- THEN it does not decide whether a concrete host should install the package
- AND host installation policy is expressed through host or configuration modules
