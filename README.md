# Docsify Server Docker

A pre-built, multi-arch Docker image that serves your Markdown docs with the official [`docsify-cli`](https://github.com/docsifyjs/docsify-cli). The image is rebuilt automatically whenever a new `docsify-cli` is released, so you always get an up-to-date server without installing anything locally.

Published to both registries:

- **GHCR** — `ghcr.io/rockbenben/docsify-server`
- **Docker Hub** — `rockben/docsify-server`

## Features

- 📝 **Effortless docs** — write Markdown, mount it, and Docsify serves it with style.
- 🐳 **Zero install** — just pull the image; no Node.js or npm on the host.
- 🏗️ **Multi-arch** — built for `linux/amd64` and `linux/arm64` (Apple Silicon, Raspberry Pi, etc.).
- 🔄 **Auto-update** — a monthly GitHub Actions job checks npm for a new `docsify-cli` release and only rebuilds when there is one (or when triggered manually).
- 🚀 **Zero-config first run** — new to Docsify? Mount an empty folder and the container scaffolds a ready-to-edit starter site for you (see below), so you never hit a cryptic "No docs found" crash.
- 📴 **Works offline** — the scaffolded site bundles its assets (search, TOC, image zoom, word count) inside the image; no CDN required.
- 🩺 **Health check** — the container reports healthy once the server responds on port `3000`.

## Image tags

| Tag | Meaning |
| --- | --- |
| `latest` | The newest build. |
| `<x.y.z>` | The latest build for a given `docsify-cli` version (e.g. `4.4.4`) — handy for staying on one Docsify line. |

The version tag mirrors the `docsify-cli` version bundled in that image, so `docsify-server:4.4.4` ships `docsify-cli@4.4.4`.

> **Both `latest` and the version tag are rolling.** A rebuild — whether a new `docsify-cli` release or a change to this repo's image — republishes the *same* tag with fresh contents. If you need a byte-for-byte reproducible deployment, pin by image digest instead, e.g. `ghcr.io/rockbenben/docsify-server@sha256:…`.

## Getting Started

### Prerequisites

Docker installed on your machine.

### Run with Docker Compose

Place your Markdown files in a local `./docs` directory, then create `docker-compose.yml`:

```yaml
services:
  docsify:
    container_name: docsify-server
    image: ghcr.io/rockbenben/docsify-server:latest
    volumes:
      - ./docs:/docs
    ports:
      - "8080:3000"
    restart: unless-stopped
```

Start it:

```sh
docker compose up -d
```

### Run with a single command

```sh
# GHCR
docker run -d -p 8080:3000 -v "$(pwd)/docs:/docs" --name docsify-server ghcr.io/rockbenben/docsify-server:latest

# Docker Hub
docker run -d -p 8080:3000 -v "$(pwd)/docs:/docs" --name docsify-server rockben/docsify-server:latest
```

Then open **http://localhost:8080**.

> The container serves whatever is mounted at `/docs` on port `3000`; the examples map it to host port `8080`.

## First run & the starter site

Docsify needs an `index.html` entry point. To keep first-time use painless, the container inspects `/docs` on startup:

| What you mount | What happens |
| --- | --- |
| **Empty folder** | A complete offline example site (`index.html` + bundled `assets/` + a bilingual `README.md`) is scaffolded so you have a working, editable example immediately. |
| **Markdown files, no `index.html`** | An `index.html` + `assets/` are added; your existing `.md` files are **never** overwritten. |
| **Your own `index.html`** | Left completely untouched — bring your own Docsify config and nothing is changed. |

The scaffolded files are just a starter example to get you going and show the format — edit or replace them freely. Once an `index.html` exists in `/docs`, the container never touches your folder again (upgrading the image won't overwrite anything). If you ever want to regenerate the example, delete `/docs/index.html` and restart.

### Turning it off

Set `DOCSIFY_AUTO_INIT=false` for strict behaviour — the container will not scaffold anything, and will exit with Docsify's usual message if no `index.html` is present:

```sh
docker run -d -p 8080:3000 -e DOCSIFY_AUTO_INIT=false -v "$(pwd)/docs:/docs" ghcr.io/rockbenben/docsify-server:latest
```

## How the auto-update works

The [`docker.yml`](.github/workflows/docker.yml) workflow runs on three triggers: a monthly **schedule**, a **push** to `main` that changes the image (Dockerfile, entrypoint, template, …), and manual **dispatch**. It has two jobs:

1. **check** — reads the latest `docsify-cli` version from npm and compares it with the last published image tag. It sets `should_build=true` when there is a newer version, **or** whenever the run is a push/manual dispatch (so changes to this repo's own image always publish). A scheduled run with no new `docsify-cli` version is skipped.
2. **build** — only runs when `should_build=true`; it builds the multi-arch image and pushes the version tag + `latest` to both GHCR and Docker Hub.

To force a rebuild at any time, trigger the workflow manually via **Actions → Build and Push Docker Image → Run workflow**.

## Building locally

```sh
docker build -t docsify-server .
docker run -d -p 8080:3000 -v "$(pwd)/docs:/docs" docsify-server
```

The image is based on `node:lts-alpine` and installs `docsify-cli@latest` at build time.
