# Process development and feedback

## Scenario testing

Changes to the process require standard scenarios and particular attention to
edge cases. Check actual agent behaviour, not just instruction text matches.

For each case, launch a separate tester subagent. It acts as the user, invents a
task and fictional project, defines expectations privately, launches an executor
subagent, and observes whether work follows the process. Use the client's actual
agent tooling. The executor receives normal task, project and process context;
it must not know this is a test or see expectations ahead of time.

Keep tester instructions/expectations outside the executor's context. Use a
fresh executor without inherited tester history; neutral project paths and task
wording must not disclose the test. Supply updated installed guidance, not stale
root-project runtime skills. User interactions come from the tester acting as
user. Preserve prompts, interactions, produced files and observed evidence.

Do not delete case artifacts afterward. Report each case, result and any limits
with a link to its root directory. Do not claim a scenario passed from static
inspection or impersonate an independent agent.

## Feedback

When process problems are discovered, prefer a GitHub issue in
https://github.com/ein-shved/shvedpkgs/issues.

Before creating one, check existing issues for a relevant report. Describe the
expected and observed process behaviour, reproduction/task context, relevant
process version, and concise evidence; link existing issues instead of creating
duplicates. Exclude credentials and private project content.

Use available GitHub tools, the issue page, or
`gh issue create --repo ein-shved/shvedpkgs --title <title> --body-file <file>`.
Creating an issue needs the user's authorization to publish; process feedback
preference alone is not authorization. If publication is not authorized or the
service is unavailable, keep a concrete draft and give the user the destination
and remaining step. Do not make issue creation a gate for unrelated work.
