---
description: Run formatting, tests, then create a PR with proper commits
argument-hint: [optional PR title or description]
---

# Create Pull Request

You are tasked with preparing and creating a pull request by running formatting, tests, and then pushing and creating the PR.

## Pre-flight Checks

Before proceeding, verify:

1. **Not on main/master branch:**
   ```bash
   git branch --show-current
   ```
   - If on `main` or `master`, stop and ask the user to create a feature branch first

2. **Check for uncommitted changes:**
   ```bash
   git status --porcelain
   ```
   - Note any uncommitted changes - they will be included in the formatting step

## Step 1: Run Formatting

1. Run the unified formatter:
   ```bash
   just format
   ```

2. Check if any files were modified:
   ```bash
   git status --porcelain
   ```

3. **If files were changed by formatting:**
   - Stage all formatting changes:
     ```bash
     git add -A
     ```
   - Create a dedicated formatting commit:
     ```bash
     git commit -m "style: Apply code formatting"
     ```
   - Inform the user: "Created formatting commit with X files changed"

4. **If no files were changed:**
   - Inform the user: "No formatting changes needed"
   - Skip the formatting commit

## Step 2: Run Tests

1. Run the full check suite:
   ```bash
   just check
   ```

2. **If tests pass:**
   - Proceed to Step 3

3. **If tests fail:**
   - Use AskUserQuestion to ask the user:
     - **Option A: Abort** - Stop PR creation and let user fix the issues
     - **Option B: Continue anyway** - Proceed with PR creation (will note test failures in PR description)
   - If user chooses to abort, stop here and summarize what needs to be fixed
   - If user chooses to continue, note that tests failed for the PR description

## Step 3: Push and Create PR

1. **Push the branch:**
   ```bash
   git push -u origin HEAD
   ```

2. **Determine PR title and body:**
   - If `$ARGUMENTS` was provided, use it as the PR title/description basis
   - Otherwise, analyze the commits on this branch vs main to generate a summary:
     ```bash
     git log main..HEAD --oneline
     ```

3. **Create the PR:**
   - Use `gh pr create` with proper formatting
   - If tests failed, include a warning in the PR body
   - Format:
     ```bash
     gh pr create --title "PR_TITLE" --body "$(cat <<'EOF'
     ## Summary
     - [Bullet points summarizing changes]

     ## Test plan
     - [ ] [Testing checklist items]

     [If tests failed: **Warning**: Tests were failing at time of PR creation. See CI for details.]

     ---
     Generated with [Claude Code](https://claude.com/claude-code)
     EOF
     )"
     ```

4. **Report the PR URL:**
   - Show the user the PR URL
   - Summarize what was done (formatting commit if any, test status, PR created)

## Important Notes

- **Formatting commit isolation**: The formatting commit should ONLY contain formatting changes, never mixed with feature changes
- **Test failures**: Always inform the user about test failures and let them decide whether to proceed
- **Clean workflow**: This command assumes work is already committed. If there are uncommitted changes, they will be formatted and included in the formatting commit
- **Conventional commits**: Use conventional commit format for the formatting commit (`style: Apply code formatting`)
