# How to Copy `.env` files into [Codex](https://openai.com/index/introducing-the-codex-app/) macOS app worktrees.

## The problem

The Codex macOS app creates isolated git worktrees for each task, but doesn't have a feature to auto copy `.env` files, so the environment is broken from the start.

## Setup

### 1. Copy the script into your project

```bash
mkdir -p scripts
curl -o scripts/copy-env.sh \
  https://raw.githubusercontent.com/onecuriousmindset/worktree-env/main/copy-env.sh
chmod +x scripts/copy-env.sh
```

### 2. Edit the `MAIN_PROJECT` path

Open `scripts/copy-env.sh` and set `MAIN_PROJECT` to the absolute path of your main project — the one that has your `.env` files:

```bash
MAIN_PROJECT="/path/to/your-project"
```

### 3. Create Codex Environment
1. From the sidebar, in the bottom left, click "Personal" to open settings
2. Then click "Environements" from the settings sidebar
3. Create or open the existing env for your project.
4. Copy the path to the script in the setup part

```
./scripts/copy-env.sh
```
<img width="800" height="140" alt="Screenshot 2026-02-02 at 23 26 42" src="https://github.com/user-attachments/assets/85e8189a-441b-45d9-935d-25bef572d1a7" />

That's it. Next time Codex spins up a worktree, your `.env` files will be there.

## What it copies

All files matching `.env*` (`.env`, `.env.local`, `.env.development`, etc.) from anywhere in your project tree, preserving directory structure. It skips `node_modules`, `.git`, `worktrees`, and `.codex` directories.

Files that already exist in the destination are never overwritten.

## For regular git worktrees

If you're using `git worktree add` directly (not via Codex), set up a **post-checkout hook** instead — it fires automatically whenever a worktree is created:

```bash
# .githooks/post-checkout (or .git/hooks/post-checkout)
#!/usr/bin/env bash
set -euo pipefail
/path/to/your/project/scripts/copy-env.sh
```

Then configure git to use your hooks directory:

```bash
git config core.hooksPath .githooks
```
