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

## Quick start

### 1. Get an account

New to Xsolla? Create a Publisher Account without leaving the terminal:

```bash
xsolla publisher signup
```

This walks through email confirmation, provisions your account, and saves your **Merchant ID** and **Project ID** to config. Your API key is printed once — save it.

### 2. Sign in

```bash
xsolla auth login
```

Runs an OAuth2 + PKCE browser flow and stores the token in your OS keychain (macOS Keychain / Windows Credential Manager). It is loaded and refreshed automatically on every command — the CLI never asks for your password. Check your session with `xsolla auth status`.

For CI/CD and server-to-server use, set an API key instead. An explicit environment variable takes precedence over the keychain token:

```bash
export XSOLLA_API_KEY="your-api-key"
```

> Find your key in **Publisher Account → Company → API Keys**, or generate one with `xsolla publisher create-api-key`.

### 3. Configure

If you already have an account:

```bash
xsolla config init
# or set values individually
xsolla config set merchant_id YOUR_MERCHANT_ID
xsolla config set project_id YOUR_PROJECT_ID
```

Testing? Switch to sandbox so you never touch live money:

```bash
xsolla config set sandbox true
```

### 4. Make your first calls

```bash
# List catalog items
xsolla catalog list-items --project-id 301567

# Create a virtual item
xsolla catalog create-items --project-id 301567 \
  --sku sword_01 \
  --name '{"en":"Sword"}' \
  --is-free=false \
  --prices '{"USD":{"amount":4.99}}'

# Create a payment token
xsolla payments create-token \
  --merchant-id 870314 \
  --settings '{"project_id":301567,"currency":"USD","mode":"sandbox"}' \
  --user '{"id":{"value":"player_1"},"email":{"value":"test@example.com"}}' \
  --purchase '{"checkout":{"amount":9.99,"currency":"USD"}}'

# Search transactions, as JSON
xsolla payments search-transactions \
  --merchant-id 870314 \
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

Each release also ships a per-archive [SBOM](https://en.wikipedia.org/wiki/Software_supply_chain) (`*.sbom.json`) so you can inspect dependencies without unpacking the binary.

## Documentation

- **Developer portal:** [developers.xsolla.com/doc/cli](https://developers.xsolla.com/doc/cli)
- **Publisher Account:** [publisher.xsolla.com](https://publisher.xsolla.com)

## Support

- **Tap issues** (install, formula, `brew` errors): [github.com/xsolla/homebrew-xsolla-cli/issues](https://github.com/xsolla/homebrew-xsolla-cli/issues)
- **CLI questions and product help:** [developers.xsolla.com](https://developers.xsolla.com)

## License

This tap is released under the MIT License — see [LICENSE](./LICENSE). The Xsolla CLI itself is licensed under Apache-2.0.
