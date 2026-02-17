# Mac Setup Guide for Claude Development Stack

## Overview
This guide provides practical, actionable instructions for setting up Claude Desktop, Claude Code, and related development tools on macOS. It focuses on security best practices, proper configuration management, and avoiding common pitfalls.

## Prerequisites

- macOS 12.0 or later
- Administrator access for software installation
- Basic command-line familiarity
- GitHub account (for GitHub MCP integration)

## Quick Start Checklist

- [ ] Install Claude Desktop
- [ ] Install Claude Code
- [ ] Configure local MCP servers (optional)
- [ ] Set up remote Connectors via Desktop UI (optional)
- [ ] Import MCP configuration to Claude Code
- [ ] Install browser extensions (optional)
- [ ] Run acceptance tests

## Installation Steps

### 1. Install Claude Desktop

**Official Download**:
- Visit [claude.ai](https://claude.ai) and download Claude Desktop for macOS
- Or check Claude's official documentation for current download links

**Installation**:
```bash
# After downloading .dmg file
open Claude-Desktop-*.dmg

# Drag Claude app to Applications folder
# Then eject the disk image
```

**Verify Installation**:
```bash
# Check application exists
ls -la /Applications/Claude.app

# Get version (if CLI available)
/Applications/Claude.app/Contents/MacOS/Claude --version || \
defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString
```

### 2. Install Claude Code

**Official Installation**:
- Follow official Claude Code installation documentation
- Verify the Claude CLI tool is available after installation

**Verify Installation**:
```bash
# Check CLI is available
which claude

# Check version
claude --version
```

### 3. Install Homebrew (Recommended for Dependencies)

If not already installed:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify installation
brew --version
```

### 4. Install Node.js (Required for npx-based MCP Servers)

```bash
# Via Homebrew
brew install node

# Verify
node --version
npm --version
```

## MCP Configuration Architecture

### Understanding Local vs Remote MCPs

#### Local MCP Servers (JSON Configuration)
**What**: Processes that run locally on your machine  
**Configuration**: `claude_desktop_config.json` file  
**Examples**: 
- Filesystem access (controlled directories)
- Local memory/cache servers
- Local development tools
- Database clients

**Characteristics**:
- Run as local processes
- Direct system/filesystem access
- Configured via JSON file
- Imported to Claude Code via CLI

#### Remote MCP Servers (Connectors - UI Managed)
**What**: Hosted integrations with cloud services  
**Configuration**: Desktop UI → Settings → Connectors  
**Examples**:
- GitHub integration (repos, issues, PRs)
- Notion workspace access
- Zapier workflows
- Supabase projects
- Slack workspaces

**Characteristics**:
- Connect to hosted services
- API-based communication
- OAuth/token authentication
- Managed through Desktop UI, not JSON
- Each requires separate authentication

### Why This Distinction Matters

1. **Security**: Local MCPs need filesystem permissions; remote MCPs need API credentials
2. **Configuration**: Local via JSON (version controllable); remote via UI (per-installation)
3. **Portability**: Local configs can be shared; remote configs are user-specific
4. **Maintenance**: Local MCPs installed once; remote Connectors need per-user setup

## Local MCP Configuration

### Configuration File Location

**macOS**:
```bash
$HOME/Library/Application Support/Claude/claude_desktop_config.json
```

### Minimal Safe Example Configuration

See `claude_desktop_config.json` in this directory for a minimal, safe example configuration.

**Important**: 
- Start with minimal configuration
- Only add MCPs you actually need
- Never include API keys or secrets in the JSON file
- Use environment variables for sensitive data

### Recommended Local MCP Servers

#### 1. Filesystem Server (Limited Scope)
Provides controlled access to specific directories.

**Security Best Practice**: Only grant access to specific project directories, never entire drives.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/projects/allowed-dir"]
    }
  }
}
```

#### 2. Memory Server (Optional)
Provides ephemeral storage for conversation context.

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### Installing MCP Servers

Most official MCP servers are available via npm:

```bash
# Filesystem server
npx -y @modelcontextprotocol/server-filesystem --help

# Memory server
npx -y @modelcontextprotocol/server-memory --help
```

## Remote Connectors Setup (GitHub Example)

### GitHub MCP Server

**Official Documentation**: [GitHub MCP Server README](https://github.com/github/github-mcp-server)

**Recommended Approach**:
1. Visit GitHub's official MCP Server repository
2. Follow their verified setup instructions
3. Configure via Claude Desktop Connectors UI, not JSON
4. Authenticate using GitHub OAuth

**Setup Steps** (refer to official docs for current procedure):
1. Open Claude Desktop → Settings → Connectors
2. Find GitHub in available connectors
3. Click "Connect" and follow authentication flow
4. Grant appropriate repository access
5. Test connection

**Important**: Do NOT attempt to configure GitHub MCP via JSON config file. Use the Connectors UI for proper OAuth flow.

### Other Remote Integrations

Similarly, for Notion, Zapier, Supabase, etc.:
- Configure via Desktop Connectors UI
- Follow each service's official setup guide
- Authenticate separately for each service
- Never put API keys in JSON files

## Importing Configuration to Claude Code

After configuring MCPs in Claude Desktop, import to Claude Code:

```bash
# Standard import command
claude mcp add-from-claude-desktop

# Verify import
claude mcp list
```

This command:
- Reads local MCP configuration from Desktop
- Imports compatible servers to Code
- Maintains consistency between tools

**Note**: Remote Connectors configured via UI are separate and may need independent setup in Code.

## Security Best Practices

### Configuration as Code

1. **Version Control**: Track `claude_desktop_config.json` (without secrets) in git
2. **Code Review**: Review all configuration changes before applying
3. **Testing**: Test new MCPs in isolation before production use
4. **Documentation**: Document why each MCP is needed and what it accesses

### Secret Management

**Never Do**:
- ❌ Hardcode API keys in `claude_desktop_config.json`
- ❌ Commit secrets to version control
- ❌ Share configuration files with embedded credentials
- ❌ Grant MCPs more access than needed

**Always Do**:
- ✅ Use environment variables for secrets
- ✅ Use secret management tools (1Password, AWS Secrets Manager)
- ✅ Apply principle of least privilege
- ✅ Regularly audit MCP permissions
- ✅ Use deny lists for sensitive files

### Example: Secure Configuration with Environment Variables

```json
{
  "mcpServers": {
    "custom-server": {
      "command": "node",
      "args": ["$HOME/servers/custom-server.js"],
      "env": {
        "API_KEY": "${API_KEY}",
        "DB_PASSWORD": "${DB_PASSWORD}"
      }
    }
  }
}
```

Set environment variables separately:
```bash
# In ~/.zshrc or ~/.bashrc
export API_KEY="your-api-key-here"
export DB_PASSWORD="your-password-here"
```

### Deny Lists for Sensitive Files

Prevent MCP filesystem servers from accessing sensitive files:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/projects"],
      "deny": [
        "Read(./.env)",
        "Read(./.env.*)",
        "Read(./config/secrets.*)",
        "Write(./.env)",
        "Read($HOME/.ssh/*)",
        "Read($HOME/.aws/*)"
      ]
    }
  }
}
```

## Common Pitfalls to Avoid

### 1. Configuration Management
❌ **Don't**: Manually copy config files with secrets  
✅ **Do**: Start from minimal example, add what you need, use environment variables

### 2. MCP Overload
❌ **Don't**: Install every available MCP "just in case"  
✅ **Do**: Only install MCPs you actually use

### 3. Secret Exposure
❌ **Don't**: Commit `claude_desktop_config.json` with API keys  
✅ **Do**: Exclude secrets, use environment variables, add `.gitignore` rules

### 4. Permission Creep
❌ **Don't**: Grant filesystem MCP access to entire home directory  
✅ **Do**: Limit to specific project directories with explicit deny lists

### 5. Configuration Drift
❌ **Don't**: Maintain separate configs for Desktop and Code  
✅ **Do**: Use Desktop as authority, import to Code regularly

## Verification and Testing

### System Acceptance Test

After setup, run acceptance tests:

```bash
# Check all tools installed
claude --version
node --version
npm --version

# Verify Desktop config
ls -la "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# List imported MCPs in Code
claude mcp list

# Test basic MCP functionality
# (This step is interactive - test in Claude Desktop/Code)
```

See `ACCEPTANCE_TEST.md` in the migration docs for comprehensive testing procedures.

## Troubleshooting

### Claude Code CLI Not Found

```bash
# Check installation
which claude

# Add to PATH if needed (add to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:/path/to/claude/bin"
```

### MCP Configuration Not Loading

```bash
# Validate JSON syntax
python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Check file permissions
ls -la "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Restart Claude Desktop after config changes
```

### Import Command Fails

```bash
# Ensure Claude Desktop config exists
test -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" && echo "Found" || echo "Missing"

# Verify Claude Code is updated
claude --version

# Check for error details
claude mcp add-from-claude-desktop --verbose  # if available
```

## Additional Resources

### Official Documentation
- [Claude Code Settings](https://code.claude.com/docs/de/settings)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)

### Setup Guides
- [Setting Up the Official GitHub MCP Server](https://dev.to/debs_obrien/setting-up-the-official-github-mcp-server-a-simple-guide-707)

### Security
- See `SECURITY.md` in this directory for detailed security guidance

## Next Steps

1. **Complete Setup**: Install all required tools
2. **Configure MCPs**: Start with minimal local configuration
3. **Add Connectors**: Set up remote integrations via UI as needed
4. **Import to Code**: Run `claude mcp add-from-claude-desktop`
5. **Test Everything**: Run acceptance tests
6. **Document Your Setup**: Keep notes on what you configured and why
7. **Regular Maintenance**: Review and update configurations periodically

## Getting Help

- Check official Claude documentation
- Review GitHub issues for specific MCP servers
- Consult security guide for permission questions
- Test changes in isolation before production use

---

**Remember**: Treat all configurations as code. Review changes, test thoroughly, and never commit secrets to version control.
