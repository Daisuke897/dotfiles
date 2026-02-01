# GitHub Copilot CLI Skills

This directory contains custom skills for the GitHub Copilot CLI, extending its functionality with specialized commands.

## Available Skills

### 1. assume-cloudformation-role

Assume AWS IAM role for CloudFormation operations and set temporary credentials as environment variables.

- **Use case**: Before CloudFormation operations (create, delete, update stacks)
- **Output**: Sets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` environment variables
- **Prerequisites**: AWS CLI, jq, AWS profile configured

See [SKILL.md](./assume-cloudformation-role/SKILL.md) for details.

### 2. aws-sso-login

Authenticate to AWS using Single Sign-On (SSO) for a specified profile.

- **Use case**: When AWS CLI operations require SSO authentication or SSO session has expired
- **Output**: Initiates SSO authentication flow
- **Prerequisites**: AWS CLI configured with SSO

See [SKILL.md](./aws-sso-login/SKILL.md) for details.

### 3. commit-message-generator

Generate appropriate commit messages based on Git diffs, following Conventional Commits format.

- **Use case**: Creating standardized, meaningful commit messages
- **Input**: Git diff (staged or working directory changes)
- **Output**: Suggested commit messages with Conventional Commits format
- **Prerequisites**: Git

See [SKILL.md](./commit-message-generator/SKILL.md) for details.

### 4. forgejo-cli-ops

Use the Forgejo CLI (`fj`) to authenticate and operate on a Forgejo instance (issues, PRs, repositories).

- **Use case**: Working with self-hosted Forgejo repositories
- **Features**: Host handling, authentication, issue/PR/repo operations
- **Prerequisites**: `fj` CLI installed, Forgejo PAT created

See [SKILL.md](./forgejo-cli-ops/SKILL.md) for details.

## Integration

These skills are managed via dotfiles for consistency across machines.

**Symlink setup**:
```bash
~/.copilot/skills → ~/dotfiles/copilot/skills
```

After cloning dotfiles on a new machine, create the symlink:
```bash
ln -s ~/dotfiles/copilot/skills ~/.copilot/skills
```

## Usage

Skills are accessed through the GitHub Copilot CLI:
```bash
copilot skill <skill-name>
```

Refer to individual `SKILL.md` files for detailed usage instructions and examples.
