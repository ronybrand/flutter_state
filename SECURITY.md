# Security Policy

## Supported versions

This is a single-branch portfolio project (no maintained release lines): security fixes land on
`main` only. There is no LTS/backport policy.

## Reporting a vulnerability

Please **do not** open a public GitHub issue for a suspected vulnerability. Instead, use
[GitHub's private vulnerability reporting](../../security/advisories/new) for this repository
(Security tab, "Report a vulnerability"), or contact the maintainer through the email on the
[GitHub profile](https://github.com/ronybrand).

Include, where applicable: a description and impact, steps to reproduce, and the affected screen
or module.

This project is maintained on a best-effort basis (no SLA), but reports are taken seriously.

## Scope

In scope: the application code in this repository and its CI/CD workflows.

Out of scope: the [`estado`](https://github.com/ronybrand/estado) API it talks to, covered by its
own policy. Dependency vulnerabilities are tracked by Dependabot and Trivy.

## What this app already does

- **Session token in the OS keychain** (`flutter_secure_storage`: iOS Keychain, Android Keystore),
  not in plain storage. It is mirrored in memory only because the HTTP interceptor needs it
  synchronously.
- **The session is read before the first frame**, so no guard ever acts on an "unknown yet" state.
  A stored token that is expired or malformed is dropped and deleted at launch, and a timer ends the
  session at the JWT's `exp`. The client-side `exp` decode is a UI hint only: the signature is never
  verified here, and the backend authorizes every request.
- **No secrets in the binary.** `--dart-define` values are compiled into the app, so the only one
  (`API_URL`) is a public url. The bearer token is attached only to requests aimed at the API's own
  base url, never to a look-alike host (`https://api.example.comevil.com`).
- **A failing keychain degrades to "logged out"** instead of crashing; a failed write keeps the
  session in memory for that run only.
- **Path parameters are validated** before they reach the API (a deep link can put anything in
  `:id`).
- **Request correlation ids** (`X-Request-Id`, a random v4 uuid) are generated once per action; only
  a uuid echoed by the server is ever displayed.
- **The Android release manifest declares `INTERNET` itself** (the template only does so for debug
  and profile builds, which would leave a release build unable to reach the API).
- Dependabot for pub packages and GitHub Actions, and [Trivy](.github/workflows/ci.yml) scanning the
  repository (CodeQL does not analyze Dart).

## Known limits

- No certificate pinning: the app trusts the system certificate store.
- A rooted/jailbroken device can read the keychain, which is outside what an app can defend.
- On the web build, `flutter_secure_storage` falls back to encrypted browser storage, which is
  weaker than an OS keychain.
- Android release builds block cleartext HTTP by default and iOS enforces ATS: keep the API on
  `https`.
