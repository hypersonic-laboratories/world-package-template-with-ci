# Helix World Package — Auto Deploy

This repo is a template for publishing a Helix world package (or any package) to the Helix vault automatically, every time you push to `main`. No manual uploads — commit your world, push, and the GitHub Action does the rest.

## What you need

- A Helix account with an **API access token**.
- A package already created in Helix (you need its **package ID** and **package version ID**).
- A GitHub repo made from this template.

## Setup (one time per repo)

1. **Add your API token as a repo secret.**
   Settings → Secrets and variables → Actions → **Secrets** tab → *New repository secret*
   - Name: `ACCESS_TOKEN`
   - Value: your Helix API token

2. **Add the API URL as a repo variable.**
   Settings → Secrets and variables → Actions → **Variables** tab → *New repository variable*
   - Name: `API_URL`
   - Value: the Helix API base URL — e.g. `https://staging-hub.helixgame.com` for staging or `https://api.helixgame.com` for production

   If this variable is missing, the workflow fails fast with a clear error — that's intentional, so you don't accidentally deploy to the wrong environment.

3. **Fill in `metadata.json`** at the repo root with your package info. The two IDs are what the deploy script uses to know *which* package version to update:

   ```json
   {
     "package": { "id": "<your-package-id>", "...": "..." },
     "id": "<your-package-version-id>",
     "config": { "...": "your game config here" }
   }
   ```

That's it. Push to `main` and watch the Actions tab.

## What goes in the repo

| Path              | Required | What it is                                                                              |
| ----------------- | -------- | --------------------------------------------------------------------------------------- |
| `metadata.json`   | ✅       | Tells the runner which package/version to update. Not uploaded — just read.             |
| `content/`        | ✅       | Your world's content files. Gets zipped and uploaded.                                   |
| `scripts/`        | optional | Server scripts. If present, gets bundled alongside `content/`.                          |
| `configFile.json` | optional | A game config file. If present, uploaded as the package's downloadable metadata asset.  |
| `preview.jpg`     | optional | Thumbnail (not auto-uploaded by this workflow).                                         |

## What the deploy does

When you push to `main` (or run the workflow manually from the Actions tab), three steps run in order:

1. **Archive** — `content/` and `scripts/` are tarred + gzipped into a single `content.tar.gz`. An xxh3 hash of the archive is computed (the Helix server uses it to verify what arrived).
2. **Register** — calls `PATCH /api/v1/package-versions/<your-version-id>` with the list of files we're about to upload. Helix responds with pre-signed upload URLs.
3. **Upload** — streams `content.tar.gz` (and `configFile.json` if present) to those URLs. Large files (>5 GB) auto-use multipart upload.

If anything fails, the run stops and the logs tell you what went wrong.

## Running it manually

Actions tab → *Deploy Package* → **Run workflow**. You can leave the "API URL" field blank to use the repo variable, or type a different URL to override for that one run (useful for testing against a different environment).

## Troubleshooting

- **"API_URL is not set"** — you skipped step 2 above. Add the repo variable.
- **"metadata.json not found"** — the file must be at the repo root, named exactly `metadata.json`.
- **Uploaded metadata file downloads as binary instead of JSON** — re-run the deploy; earlier runs may have stored it with the wrong Content-Type.
- **"content folder is required but not found"** — create a `content/` folder at the repo root and put your world files in it.

## Using a different API environment

Two ways:

- **Permanent**: change the `API_URL` repo variable.
- **One-off**: use the Run workflow button and paste the URL into the *apiUrl* input.

Nothing is hardcoded — the workflow won't silently point somewhere unexpected.
