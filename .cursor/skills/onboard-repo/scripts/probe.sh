#!/usr/bin/env bash
# .cursor/skills/onboard-repo/scripts/probe.sh
# Deterministic repo-onboarding probe. Detects language, framework,
# package manager, test runner, and surfaces hot files.
#
# Usage:
#   bash .cursor/skills/onboard-repo/scripts/probe.sh [path]
#
# Output: human-readable structured report on stdout. Exit 0 on
# success even when individual checks fail (probe is best-effort).

set -u

target="${1:-.}"

if [ ! -d "$target" ]; then
  echo "error: '$target' is not a directory" >&2
  exit 1
fi

cd "$target" 2>/dev/null || { echo "error: cannot cd to '$target'" >&2; exit 1; }
abs_path=$(pwd)

echo "=== onboard-repo probe ==="
echo "path: $abs_path"
echo "probed_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# ─── Language detection ───────────────────────────────────────────────

echo "## Language signals"
[ -f "package.json" ]      && echo "- TypeScript/JavaScript (package.json present)"
[ -f "tsconfig.json" ]     && echo "  - TypeScript explicitly (tsconfig.json present)"
[ -f "pyproject.toml" ]    && echo "- Python (pyproject.toml present)"
[ -f "requirements.txt" ]  && echo "- Python (requirements.txt present)"
[ -f "setup.py" ]          && echo "- Python (setup.py present — legacy)"
[ -f "Pipfile" ]           && echo "- Python (Pipfile — pipenv)"
[ -f "go.mod" ]            && echo "- Go (go.mod present)"
[ -f "Cargo.toml" ]        && echo "- Rust (Cargo.toml present)"
[ -f "Gemfile" ]           && echo "- Ruby (Gemfile present)"
[ -f "pom.xml" ]           && echo "- Java (pom.xml — maven)"
[ -f "build.gradle" ] || [ -f "build.gradle.kts" ] && echo "- Java/Kotlin (gradle present)"
[ -f "composer.json" ]     && echo "- PHP (composer.json present)"
echo ""

# ─── Package manager detection ────────────────────────────────────────

echo "## Package manager"
if [ -f "pnpm-lock.yaml" ]; then echo "- pnpm (pnpm-lock.yaml)"
elif [ -f "yarn.lock" ];     then echo "- yarn (yarn.lock)"
elif [ -f "package-lock.json" ]; then echo "- npm (package-lock.json)"
elif [ -f "bun.lockb" ];     then echo "- bun (bun.lockb)"
elif [ -f "package.json" ];  then echo "- node (package.json present, no lockfile — pick npm by default)"
fi
if [ -f "uv.lock" ];                then echo "- uv (uv.lock)"
elif [ -f "poetry.lock" ];          then echo "- poetry (poetry.lock)"
elif [ -f "Pipfile.lock" ];         then echo "- pipenv (Pipfile.lock)"
elif [ -f "requirements.txt" ];     then echo "- pip (requirements.txt)"
fi
[ -f "go.sum" ]    && echo "- go modules (go.sum)"
[ -f "Cargo.lock" ] && echo "- cargo (Cargo.lock)"
echo ""

# ─── Framework hints ──────────────────────────────────────────────────

echo "## Framework hints"
if [ -f "package.json" ] && command -v jq >/dev/null 2>&1; then
  deps=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys | .[]' package.json 2>/dev/null)
  echo "$deps" | grep -qx "next"          && echo "- Next.js"
  echo "$deps" | grep -qx "react"         && echo "- React"
  echo "$deps" | grep -qx "vue"           && echo "- Vue"
  echo "$deps" | grep -qx "svelte"        && echo "- Svelte"
  echo "$deps" | grep -qx "vite"          && echo "- Vite"
  echo "$deps" | grep -qx "express"       && echo "- Express"
  echo "$deps" | grep -qx "fastify"       && echo "- Fastify"
  echo "$deps" | grep -qx "@nestjs/core"  && echo "- NestJS"
  echo "$deps" | grep -qx "drizzle-orm"   && echo "- Drizzle ORM"
  echo "$deps" | grep -qx "prisma"        && echo "- Prisma"
  echo "$deps" | grep -qx "@playwright/test" && echo "- Playwright"
  echo "$deps" | grep -qx "vitest"        && echo "- Vitest"
  echo "$deps" | grep -qx "jest"          && echo "- Jest"
  echo "$deps" | grep -qx "ai"            && echo "- Vercel AI SDK"
  echo "$deps" | grep -qx "tailwindcss"   && echo "- Tailwind CSS"
fi
if [ -f "pyproject.toml" ]; then
  grep -qE 'fastapi'  pyproject.toml && echo "- FastAPI"
  grep -qE 'flask'    pyproject.toml && echo "- Flask"
  grep -qE 'django'   pyproject.toml && echo "- Django"
  grep -qE 'pytest'   pyproject.toml && echo "- pytest (test runner)"
  grep -qE '\bruff\b' pyproject.toml && echo "- ruff (lint/format)"
  grep -qE 'mypy'     pyproject.toml && echo "- mypy (typecheck)"
  grep -qE 'pydantic' pyproject.toml && echo "- pydantic"
  grep -qE 'sqlalchemy' pyproject.toml && echo "- SQLAlchemy"
fi
echo ""

# ─── Suggested commands ───────────────────────────────────────────────

echo "## Suggested commands"
if [ -f "package.json" ] && command -v jq >/dev/null 2>&1; then
  pm="npm"
  [ -f "pnpm-lock.yaml" ] && pm="pnpm"
  [ -f "yarn.lock" ] && pm="yarn"
  [ -f "bun.lockb" ] && pm="bun"
  echo "- install: ${pm} install"
  jq -r '.scripts // {} | to_entries | .[] | "- \(.key): '"${pm}"' run \(.key)"' package.json 2>/dev/null | head -10
fi
if [ -f "pyproject.toml" ]; then
  if [ -f "uv.lock" ]; then
    echo "- install: uv sync"
    echo "- run: uv run <command>"
    echo "- test: uv run pytest"
  elif [ -f "poetry.lock" ]; then
    echo "- install: poetry install"
    echo "- run: poetry run <command>"
    echo "- test: poetry run pytest"
  else
    echo "- install: pip install -e .[dev] (or per project README)"
    echo "- test: pytest"
  fi
fi
[ -f "go.mod" ]    && echo "- build: go build ./..." && echo "- test: go test ./..."
[ -f "Cargo.toml" ] && echo "- build: cargo build" && echo "- test: cargo test"
echo ""

# ─── Existing AI config ───────────────────────────────────────────────

echo "## Existing AI config"
[ -f "AGENTS.md" ]  && echo "- AGENTS.md present  ($(wc -l < AGENTS.md | tr -d ' ') lines)"
[ -f "CLAUDE.md" ]  && echo "- CLAUDE.md present  ($(wc -l < CLAUDE.md | tr -d ' ') lines)"
[ -f ".cursorrules" ] && echo "- .cursorrules present (legacy Cursor rules file)"
[ -d ".cursor" ]    && echo "- .cursor/ present:  $(ls .cursor/ 2>/dev/null | tr '\n' ' ')"
[ -d ".claude" ]    && echo "- .claude/ present:  $(ls .claude/ 2>/dev/null | tr '\n' ' ')"
[ -d ".github" ] && [ -d ".github/workflows" ] && \
  echo "- .github/workflows/ present:  $(ls .github/workflows/ 2>/dev/null | wc -l | tr -d ' ') workflow(s)"
echo ""

# ─── Hot files (most-touched in last 3 months) ────────────────────────

echo "## Hot files (top 15 by recent commits)"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git log --pretty=format: --name-only --since=3.months 2>/dev/null \
    | grep -v '^$' \
    | sort | uniq -c | sort -rn \
    | head -15 \
    | awk '{printf "- %s (%s commits)\n", $2, $1}'
else
  echo "- (git history unavailable)"
fi
echo ""

# ─── Repository size summary ──────────────────────────────────────────

echo "## Size summary"
if command -v find >/dev/null 2>&1; then
  total=$(find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' -not -path './venv/*' -not -path './target/*' -not -path './dist/*' -not -path './.next/*' 2>/dev/null | wc -l | tr -d ' ')
  echo "- tracked-ish files: ${total}"
fi
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  commits=$(git rev-list --count HEAD 2>/dev/null || echo "?")
  contributors=$(git log --format='%aE' 2>/dev/null | sort -u | wc -l | tr -d ' ')
  echo "- commits: ${commits}"
  echo "- contributors: ${contributors}"
fi
echo ""

echo "=== probe complete ==="
exit 0
