# Xsolla CLI — Homebrew Tap

![License](https://img.shields.io/github/license/xsolla/homebrew-xsolla-cli)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux-lightgrey)

Official [Homebrew](https://brew.sh) tap for the **Xsolla CLI** — the command-line interface for the [Xsolla](https://xsolla.com) platform.

> **Go · Single binary · OpenAPI-driven · Cross-platform**

Manage payments, catalog, webshop checkout, authentication, and other Xsolla services from your terminal. Product commands are generated from OpenAPI 3.x specs, so they always match the live API.

---

## Install

```bash
brew tap xsolla/xsolla-cli
brew install xsolla
```

No GitHub token, no SSO authorization, and no Go toolchain required — the tap installs a prebuilt binary from the Xsolla CDN.

On Apple Silicon, if Homebrew reports `Cannot install under Rosetta 2 in ARM default prefix`, rerun from an ARM shell:

```bash
arch -arm64 brew install xsolla
```

Confirm it worked:

```bash
xsolla --version
```

---

## Authentication

**Start here.** Almost every command needs credentials, and most first-run problems are auth problems.

### Sign in

```bash
xsolla auth login
```

This runs an OAuth2 + PKCE flow in your browser and stores the token in your OS keychain (macOS Keychain / Windows Credential Manager). The token is loaded and refreshed automatically on every subsequent command.

**The CLI never asks for your password.** Browser login is the only interactive sign-in path.

### No account yet?

Create a Publisher Account without leaving the terminal:

```bash
xsolla publisher signup
```

This walks through email confirmation, provisions the account, saves your **Merchant ID** and **Project ID** to config, and prints an **API key** once — save it.

### Check, switch, and sign out

```bash
xsolla auth status           # who am I, and is my token still valid?
xsolla auth list-account     # stored accounts (keychain slots)
xsolla auth switch-account   # change the active account
xsolla auth get-token        # print the current access token
xsolla auth logout           # remove stored credentials
```

### CI/CD and server-to-server

There's no browser in a pipeline, so use an API key instead:

```bash
export XSOLLA_API_KEY="your-api-key"        # macOS / Linux
$env:XSOLLA_API_KEY = "your-api-key"        # Windows PowerShell
```

Basic Auth engages automatically once **both** `merchant_id` (from config) and `XSOLLA_API_KEY` are set — it's required for payments and catalog commands. `XSOLLA_TOKEN` is also honored if you need to supply a Bearer token directly.

> Find your key in **Publisher Account → Company → API Keys**, or generate one with `xsolla publisher create-api-key`.

### Getting a 401 or 403 after a successful login?

**An explicit `XSOLLA_API_KEY` takes precedence over your keychain token.** A stale or wrong key exported in your shell profile will shadow a perfectly good browser session, and the failure looks like a login problem rather than an environment problem. Check it first:

```bash
echo $XSOLLA_API_KEY     # is something set that you forgot about?
xsolla auth status       # what the CLI thinks it's using
unset XSOLLA_API_KEY     # fall back to the keychain token
```

Add `--verbose` to any command to see the request URL, headers, and response on stderr, with secrets redacted.

### Publisher vs. player identities

Some flows act as an operator, others as an end user. Pick per invocation:

```bash
xsolla auth login --auth-context xsolla-id     # sign in as a player (Xsolla ID)
xsolla webshop ... --auth-context xsolla-id    # run one command as that identity
```

`publisher` is the default. Buyer-side `webshop` commands are made **as an end user** and need a player token, not a publisher credential — mixing the two is the most common source of confusing 403s.

### Testing safely

```bash
xsolla config set sandbox true    # or pass --sandbox per command
```

---

## Configure

If you already have an account:

```bash
xsolla config init
# or set values individually
xsolla config set merchant_id YOUR_MERCHANT_ID
xsolla config set project_id YOUR_PROJECT_ID
```

## Your first API calls

```bash
# List catalog items
xsolla catalog list-items --project-id <PROJECT_ID>

# Create a virtual item
xsolla catalog create-items --project-id <PROJECT_ID> \
  --sku sword_01 \
  --name '{"en":"Sword"}' \
  --is-free=false \
  --prices '{"USD":{"amount":4.99}}'

# Create a payment token
xsolla payments create-token \
  --merchant-id <MERCHANT_ID> \
  --settings '{"project_id":<PROJECT_ID>,"currency":"USD","mode":"sandbox"}' \
  --user '{"id":{"value":"player_1"},"email":{"value":"test@example.com"}}' \
  --purchase '{"checkout":{"amount":9.99,"currency":"USD"}}'

# Search transactions, as JSON
xsolla payments search-transactions \
  --merchant-id <MERCHANT_ID> \
  --from "2026-01-01" --to "2026-12-31" --json
```

## What you can manage

| Command | What it covers |
| --- | --- |
| `auth` | Sign in, session status, multiple auth contexts |
| `catalog` | Virtual items, currencies, bundles, packages, pricing |
| `payments` | Payment tokens, Pay Station, transactions, refunds |
| `webshop` | Buyer-side cart and checkout flows |
| `shopbuilder` | Shop Builder landings and webshop sites |
| `subscriptions` | Recurring plans, trials, grace periods |
| `login` | Xsolla Login — user auth, JWT/OAuth 2.0, webhooks |
| `inventory` | Player inventory and virtual currency balances |
| `gamekeys` | Game Keys publishing and DRM code management |
| `liveops`, `liveopsanalytics` | LiveOps campaigns and analytics |
| `cloudgaming`, `offerwall`, `merchant` | Cloud gaming, offerwall, merchant APIs |
| `publisher` | Publisher Account, projects, API keys |
| `webhook` | Simulate and receive Xsolla webhooks locally |
| `config` | Profiles, merchant/project IDs, sandbox mode |
| `skills` | Bundled agent playbooks (see below) |
| `update` | Self-update to the latest release |

Run `xsolla <command> --help` for the full surface of any group.

## Useful global flags

| Flag | Effect |
| --- | --- |
| `--sandbox` | Use Xsolla sandbox endpoints |
| `--json` | Emit pure JSON to stdout — for scripting and `jq` |
| `--dry-run` | Preview actions without executing them |
| `--verbose` | Echo request/response I/O to stderr (secrets redacted) |
| `--auth-context` | `publisher` or `xsolla-id` for this invocation |
| `--profile` | Switch between named configuration profiles |
| `--log-level` | `error`, `warn`, `info`, `debug`, `trace` |

## Use it with an AI agent

The CLI ships **agent skills** — `SKILL.md` playbooks that teach Claude Code, Cursor, or Copilot how to drive it for real tasks. They're embedded in the binary but are *not* installed automatically, because `brew install` has no interactive prompt:

```bash
xsolla skills install            # this project (./.claude/skills)
xsolla skills install --global   # all projects (~/.claude/skills)
xsolla skills list               # what's available
```

Skills install outside Homebrew's prefix, so `brew uninstall xsolla` cannot remove them. Run `xsolla skills uninstall --all` first.

## Upgrade

```bash
brew update && brew upgrade xsolla
```

## Uninstall

```bash
xsolla skills uninstall --all    # if you installed skills
brew uninstall xsolla
brew untap xsolla/xsolla-cli
```

## Verifying release artifacts

Every release publishes a `checksums.txt` covering all archives and SBOMs, signed with [cosign](https://github.com/sigstore/cosign) using keyless Sigstore signing. The signature is bound to the release workflow's GitHub OIDC identity, so it attests *which workflow built the binary* rather than merely that someone held a key:

```bash
VERSION=1.9.4
BASE="https://cdn.xsolla.net/xsolla-cli/v${VERSION}"

curl -sO "${BASE}/checksums.txt"
curl -sO "${BASE}/checksums.txt.sigstore.json"

cosign verify-blob \
  --bundle checksums.txt.sigstore.json \
  --certificate-identity-regexp 'https://github\.com/xsolla/xsolla-cli/\.github/workflows/release\.yaml@.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  checksums.txt
```

The `--certificate-identity-regexp` value is an *assertion matched against the
signing certificate*, not a URL that gets fetched — `xsolla/xsolla-cli` is a private
repository, but nothing here reads it. Both `checksums.txt` and its Sigstore bundle
are served publicly from the CDN, and the bundle embeds the certificate and
transparency-log entry, so verification needs no GitHub access at all.

Each release also ships a per-archive SBOM (`*.sbom.json`) so you can inspect dependencies without unpacking the binary.

## Documentation

- **Developer portal:** [developers.xsolla.com/doc/cli](https://developers.xsolla.com/doc/cli)
- **Publisher Account:** [publisher.xsolla.com](https://publisher.xsolla.com)

## Support

- **Tap issues** (install, formula, `brew` errors): [github.com/xsolla/homebrew-xsolla-cli/issues](https://github.com/xsolla/homebrew-xsolla-cli/issues)
- **CLI questions and product help:** [developers.xsolla.com](https://developers.xsolla.com)

## License

This tap is released under the MIT License — see [LICENSE](./LICENSE). The Xsolla CLI itself is licensed under Apache-2.0.
