#!/usr/bin/env bash
# scripts/vcs-helper.sh — Unified VCS abstraction layer (GitHub/gh vs GitLab/glab vs Web fallback)
#
# Detects whether the active repository is GitHub-based or GitLab-based (including vcs.levi9.com),
# determines if the corresponding CLI (gh or glab) is installed & authenticated, and executes
# the operation or falls back gracefully to manual Git/Web UI instructions.
#
# Usage:
#   bash scripts/vcs-helper.sh <operation> [args...]
#
# Operations:
#   detect          - Prints detected VCS (github | gitlab) and active CLI (gh | glab | manual)
#   pr-list         - Lists open PRs/MRs
#   pr-view <id>    - Views details of a PR/MR
#   pr-diff <id>    - Gets the diff of a PR/MR (name-only or full)
#   pr-checks <id>  - Checks CI status of a PR/MR
#   pr-comment <id> <text|file-path> - Comments on a PR/MR
#   pr-create <title> <branch> <body-file> - Opens a PR/MR
#   pr-merge <id>   - Squash-merges a PR/MR and deletes the source branch
#   issue-list      - Lists open issues
#   issue-view <id> - Views details of an issue
#

set -uo pipefail

# --- VCS DETECTION --------------------------------------------------------

detect_vcs() {
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")

  if [[ "$remote_url" =~ "vcs.levi9.com" ]] || [[ "$remote_url" =~ "gitlab" ]]; then
    echo "gitlab"
  else
    echo "github"
  fi
}

detect_cli() {
  local vcs=$1
  if [[ "$vcs" == "gitlab" ]]; then
    if command -v glab >/dev/null 2>&1 && glab auth status >/dev/null 2>&1; then
      echo "glab"
    else
      echo "manual"
    fi
  else
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      echo "gh"
    else
      echo "manual"
    fi
  fi
}

VCS=$(detect_vcs)
CLI=$(detect_cli "$VCS")

# --- GRACEFUL FALLBACK PRINTERS -------------------------------------------

print_manual_instructions() {
  local op=$1
  local args=("${@:2}")
  
  echo >&2 "----------------------------------------------------------------------"
  echo >&2 " VCS HELPER: CLI fallback mode active ($VCS / manual)"
  echo >&2 " Reason: Required CLI (gh for GitHub, glab for GitLab) is missing or unauthenticated."
  echo >&2 " Please perform this operation manually:"
  
  case "$op" in
    pr-list)
      if [[ "$VCS" == "gitlab" ]]; then
        echo >&2 " View Merge Requests on Levi9 GitLab: https://vcs.levi9.com/ (navigate to your repo's Merge Requests)"
      else
        echo >&2 " View Pull Requests on GitHub: (navigate to your repo's Pull Requests tab)"
      fi
      ;;
    pr-view)
      local id="${args[0]:-}"
      if [[ "$VCS" == "gitlab" ]]; then
        echo >&2 " View Merge Request !${id} in your browser at vcs.levi9.com."
      else
        echo >&2 " View Pull Request #${id} in your browser."
      fi
      ;;
    pr-diff)
      local id="${args[0]:-}"
      echo >&2 " Run manually: git fetch origin && git diff main...origin/$(git branch --show-current)"
      ;;
    pr-checks)
      echo >&2 " Check the pipeline status directly on the repository's web interface."
      ;;
    pr-comment)
      local id="${args[0]:-}"
      echo >&2 " Post your comment directly on PR/MR #${id} on the Web UI."
      ;;
    pr-create)
      local title="${args[0]:-}"
      local branch="${args[1]:-}"
      echo >&2 " 1. Push branch: git push -u origin ${branch}"
      if [[ "$VCS" == "gitlab" ]]; then
        echo >&2 " 2. Open the push output URL or navigate to vcs.levi9.com to create a Merge Request: '${title}'"
      else
        echo >&2 " 2. Navigate to GitHub to open a Pull Request: '${title}'"
      fi
      ;;
    pr-merge)
      local id="${args[0]:-}"
      echo >&2 " Merge PR/MR #${id} via the Web UI (using Squash and Merge option),"
      echo >&2 " then switch to main and pull locally:"
      echo >&2 "   git switch main && git pull --ff-only"
      ;;
    issue-list)
      echo >&2 " View issues directly on the repository's web interface."
      ;;
    issue-view)
      local id="${args[0]:-}"
      echo >&2 " View Issue #${id} directly on the repository's web interface."
      ;;
  esac
  echo >&2 "----------------------------------------------------------------------"
}

# --- OPERATIONS IMPLEMENTATION ---------------------------------------------

op_detect() {
  echo "vcs=${VCS}"
  echo "cli=${CLI}"
}

op_pr_list() {
  if [[ "$CLI" == "glab" ]]; then
    glab mr list --state open
  elif [[ "$CLI" == "gh" ]]; then
    gh pr list --state open
  else
    print_manual_instructions "pr-list"
    exit 1
  fi
}

op_pr_view() {
  local id=${1:-}
  if [[ -z "$id" ]]; then
    echo >&2 "error: PR/MR number is required"
    exit 1
  fi
  
  if [[ "$CLI" == "glab" ]]; then
    glab mr view "$id"
  elif [[ "$CLI" == "gh" ]]; then
    gh pr view "$id"
  else
    print_manual_instructions "pr-view" "$id"
    exit 1
  fi
}

op_pr_diff() {
  local id=${1:-}
  local format=${2:-} # "--name-only" or empty
  
  if [[ -z "$id" ]]; then
    echo >&2 "error: PR/MR number is required"
    exit 1
  fi

  if [[ "$CLI" == "glab" ]]; then
    if [[ "$format" == "--name-only" ]]; then
      # glab doesn't have a direct name-only diff, extract from full diff or list files
      glab mr diff "$id" | grep -E '^(--- a/|\+\+\+ b/)' | sed 's/+++ b\///' | grep -v '--- a/' | sort -u || echo "(diff unavailable)"
    else
      glab mr diff "$id"
    fi
  elif [[ "$CLI" == "gh" ]]; then
    if [[ "$format" == "--name-only" ]]; then
      gh pr diff "$id" --name-only
    else
      gh pr diff "$id"
    fi
  else
    print_manual_instructions "pr-diff" "$id"
    exit 1
  fi
}

op_pr_checks() {
  local id=${1:-}
  if [[ -z "$id" ]]; then
    echo >&2 "error: PR/MR number is required"
    exit 1
  fi

  if [[ "$CLI" == "glab" ]]; then
    # In GitLab, checks are pipelines associated with MR branch
    local branch
    branch=$(glab mr view "$id" | grep -i "source branch" | awk '{print $NF}' || echo "")
    if [[ -n "$branch" ]]; then
      glab pipeline status --branch "$branch" 2>/dev/null || echo "No active CI pipeline found on branch ${branch}."
    else
      echo "No active CI pipeline found."
    fi
  elif [[ "$CLI" == "gh" ]]; then
    gh pr checks "$id"
  else
    print_manual_instructions "pr-checks" "$id"
    exit 1
  fi
}

op_pr_comment() {
  local id=${1:-}
  local input=${2:-} # raw comment string or file path
  
  if [[ -z "$id" ]] || [[ -z "$input" ]]; then
    echo >&2 "error: PR/MR number and comment input are required"
    exit 1
  fi

  local body_text="$input"
  if [[ -f "$input" ]]; then
    body_text=$(cat "$input")
  fi

  if [[ "$CLI" == "glab" ]]; then
    glab mr note "$id" --message "$body_text"
  elif [[ "$CLI" == "gh" ]]; then
    if [[ -f "$input" ]]; then
      gh pr comment "$id" --body-file "$input"
    else
      gh pr comment "$id" --body "$body_text"
    fi
  else
    print_manual_instructions "pr-comment" "$id"
    exit 1
  fi
}

op_pr_create() {
  local title=${1:-}
  local branch=${2:-}
  local body_file=${3:-}

  if [[ -z "$title" ]] || [[ -z "$branch" ]] || [[ -z "$body_file" ]]; then
    echo >&2 "error: title, branch, and body-file are required"
    exit 1
  fi

  # Git push first
  git push -u origin "$branch"

  if [[ "$CLI" == "glab" ]]; then
    glab mr create --title "$title" --description "$(cat "$body_file")" --source "$branch" --target main --yes --remove-source-branch
  elif [[ "$CLI" == "gh" ]]; then
    gh pr create --title "$title" --body "$(cat "$body_file")"
  else
    print_manual_instructions "pr-create" "$title" "$branch"
    exit 0 # return exit 0 so ship scripts can continue gracefully
  fi
}

op_pr_merge() {
  local id=${1:-}
  if [[ -z "$id" ]]; then
    echo >&2 "error: PR/MR number is required"
    exit 1
  fi

  if [[ "$CLI" == "glab" ]]; then
    glab mr merge "$id" --squash --remove-source-branch --yes
    git switch main
    git pull --ff-only
  elif [[ "$CLI" == "gh" ]]; then
    gh pr merge "$id" --squash --delete-branch
    git switch main
    git pull --ff-only
  else
    print_manual_instructions "pr-merge" "$id"
    exit 1
  fi
}

op_issue_list() {
  if [[ "$CLI" == "glab" ]]; then
    glab issue list --state open
  elif [[ "$CLI" == "gh" ]]; then
    gh issue list --state open
  else
    print_manual_instructions "issue-list"
    exit 1
  fi
}

op_issue_view() {
  local id=${1:-}
  if [[ -z "$id" ]]; then
    echo >&2 "error: Issue number is required"
    exit 1
  fi

  if [[ "$CLI" == "glab" ]]; then
    glab issue view "$id"
  elif [[ "$CLI" == "gh" ]]; then
    gh issue view "$id"
  else
    print_manual_instructions "issue-view" "$id"
    exit 1
  fi
}

# --- MAIN DISPATCHER ------------------------------------------------------

OPERATION=${1:-}
if [[ -z "$OPERATION" ]]; then
  echo >&2 "error: operation is required"
  echo >&2 "Usage: bash scripts/vcs-helper.sh <operation> [args...]"
  exit 1
fi

shift

case "$OPERATION" in
  detect)        op_detect ;;
  pr-list)       op_pr_list ;;
  pr-view)       op_pr_view "$@" ;;
  pr-diff)       op_pr_diff "$@" ;;
  pr-checks)     op_pr_checks "$@" ;;
  pr-comment)    op_pr_comment "$@" ;;
  pr-create)     op_pr_create "$@" ;;
  pr-merge)      op_pr_merge "$@" ;;
  issue-list)    op_issue_list ;;
  issue-view)    op_issue_view "$@" ;;
  *)
    echo >&2 "error: unknown operation: $OPERATION"
    exit 1
    ;;
esac
