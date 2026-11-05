# Security Policy

## Supported versions

`laiss-rails-cms` is in beta. Security fixes land on the **latest released
version** only; there is no back-porting to older `0.x` betas. Upgrade to the
newest tag.

| Version | Supported |
| --- | --- |
| latest `0.x` release | yes |
| older `0.x` releases | no — upgrade |

Pre-release tags (`0.x.y.betaN`) are supported until the next beta supersedes them.

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Use [GitHub Security Advisories](https://github.com/JulioPapel/laiss-rails-cms/security/advisories/new):

1. Go to the repository's **Security** tab.
2. Choose **Report a vulnerability**.
3. Describe the issue, the version, and the smallest reproduction you can.

This keeps the report private between you and the maintainer until a fix is
available. If you cannot use the web form, open a public issue containing **no
details** and ask for a private channel.

### What to include

- The version or commit you tested
- Rails version, Ruby version, and database adapter
- Steps to reproduce, or a proof of concept
- What an attacker gains — read access, write access, denial of service, remote
  code execution
- Any mitigation you already know of

### What to expect

- **Acknowledgement** within 5 working days.
- An assessment within 10 working days, including whether it is in scope.
- Credit in the advisory once a fix ships, unless you ask not to be named.

This is a small project with one maintainer. Please allow realistic time; if a
report goes unanswered for 14 days, the web form has failed and a public issue
asking for a private channel is appropriate.

## Scope

In scope:

- The engine: authentication boundaries, authorisation bypass, SQL injection,
  cross-site scripting, unsafe deserialisation, path traversal, file upload
  handling, tenant/site isolation.
- The admin interface, including the content-security policy.
- Anything that lets a user with a lower role act as one with a higher role.

Usually out of scope:

- Vulnerabilities in dependencies — report them upstream; tell us if the engine
  needs to change how it uses them.
- Issues that require an already-compromised admin account.
- Missing hardening headers with no demonstrated impact.
- Findings from automated scanners with no working proof of concept.

## Known security-relevant design notes

- **The core has no authentication.** `laiss_cms` expects a `current_user`
  method. Without one it raises rather than falling open, but supplying a
  permissive implementation is the host application's responsibility.
- **Authorisation is CanCan-based** and role-driven. Audit your own ability
  definitions if you extend the roles.
- **Rich-text content is restricted** to an allowlist (`valid_elements`), and
  paste is forced to plain text. That is a safety boundary for author content, not
  a substitute for output escaping in your own views.
