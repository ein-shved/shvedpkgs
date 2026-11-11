# Requirements

These requirements describe individual deployed hosts.

## REQ-001: Minimal system footprint on Gerrit

The `gerrit` host must minimize the size of its installed system while
retaining its server functionality and administrative access.

### Scenario: Optional software serves the host's needs

- WHEN optional software is considered for the `gerrit` host
- THEN it is included only when needed for server operation or administration
- AND required server functionality and administrative access remain available
