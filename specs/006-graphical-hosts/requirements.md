# Requirements

## REQ-001: Full access to pass

The primary user of a graphical host must be able to use the full functionality
of [pass — the standard Unix password manager](https://www.passwordstore.org/).

### Scenario: Full pass functionality is available

- WHEN the primary user of a graphical host uses pass
- THEN the user can use the full functionality provided by pass

### Scenario: Personal pass setup through private configuration

- GIVEN the user has the GPG key and access permissions required for their
  password repository
- WHEN the user specifies that key and repository in the private part of their
  host configuration
- THEN the configured system provides full pass functionality with access to
  the user's passwords using that key and repository

## REQ-002: Persistent password storage for applications

A graphical host must provide its primary user's applications with persistent
password storage. Saved passwords must remain available to later application
launches and after system restart and normal user sign-in.

### Scenario: An application saves and retrieves a password

- WHEN an application saves a password using the host's password storage
- THEN saving succeeds
- AND the application can retrieve the same password

### Scenario: A later application launch retrieves the saved password

- GIVEN an application has saved a password
- WHEN the application closes and starts again
- THEN the new application launch can retrieve the previously saved password
  unchanged

### Scenario: An application retrieves its password after system restart

- GIVEN an application has saved a password
- WHEN the host restarts and the user completes normal sign-in
- THEN a newly started application can retrieve the previously saved password
  unchanged

### Scenario: Browsers can store website passwords only in pass

- WHEN the primary user signs in to a website using a browser on a graphical
  host
- THEN the browser does not save the website password in any password storage
  other than pass
