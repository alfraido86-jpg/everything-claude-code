# Premium Mac AI Stack Setup Guide (2026)

**Welcome to your premium AI development setup on Mac.** This guide will help you migrate from Windows/ARM and establish Claude Desktop as your central AI command hub with seamless integration to Claude Code, VS Code Extension, and Claude Cowork.

Perfect for developers new to GitHub who want a clean, professional setup without the Windows mess.

---

## 🎯 Quick Overview: Three Stack Tiers

Choose your stack based on your workflow needs:

### Stack 1: Command Center 🎛️
**Claude Desktop + MCP Bridges**

- Best for: Migration from Windows, beginners
- Claude Desktop acts as your main hub
- Connect to GitHub, Notion, Supabase, Zapier via MCP bridges
- Simple, clean, powerful
- **Start here if you're new to the ecosystem**

### Stack 2: Multi-Agent Operator ⚡
**Parallel Claude Code Sub-Agents**

- Best for: Speed and parallel workflows
- Run multiple Claude Code agents simultaneously
- Perfect for complex projects with multiple services
- Requires understanding of git worktrees
- **Upgrade when you need more power**

### Stack 3: Full Ecosystem 🚀
**Cowork + Plugins + Automation**

- Best for: Premium power users
- Full Claude Cowork integration
- Custom plugin development
- Advanced automation workflows
- **Endgame setup for pros**

See [stack-comparison.md](./stack-comparison.md) for detailed comparison.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **macOS Sonoma (14.0+) or Sequoia (15.0+)**
- **Apple Silicon (M1/M2/M3) or Intel Mac**
- **Admin access** to your Mac
- **Claude Pro or Team account** (required for Claude Desktop)
- **GitHub account** (for MCP GitHub server)

---

## 🚀 Quick Install

The fastest way to get started:

```bash
# Clone this repository
git clone https://github.com/alfraido86-jpg/everything-claude-code.git
cd everything-claude-code/mac-setup

# Run the installer
chmod +x install.sh
./install.sh
```

The installer will:
- ✅ Install Homebrew (if needed)
- ✅ Install Claude Desktop
- ✅ Install Claude Code CLI
- ✅ Install VS Code + Claude Extension
- ✅ Set up config directories
- ✅ Copy example configs to the right locations
- ✅ Suggest Apple Shortcuts for quick access

**⚠️ Safe to re-run** - The script is idempotent and won't break existing setups.

---

## 📖 Manual Installation

Prefer to install step-by-step? Here's the full breakdown:

### Step 1: Install Homebrew

Homebrew is Mac's package manager - essential for everything:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After install, follow the terminal instructions to add Homebrew to your PATH:

```bash
# For Apple Silicon Macs (M1/M2/M3)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel Macs
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Step 2: Install Claude Desktop

Claude Desktop is your central command hub:

```bash
brew install --cask claude
```

**First Launch:**
1. Open Claude Desktop from Applications
2. Sign in with your Anthropic account
3. Verify your Pro or Team plan is active

### Step 3: Install Claude Code CLI

Claude Code brings the power of Claude to your terminal:

```bash
# Install globally via npm
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

**Alternative: Homebrew (if available)**
```bash
brew install claude-code
```

### Step 4: Install VS Code + Claude Extension

Get Claude directly in your editor:

```bash
# Install VS Code
brew install --cask visual-studio-code

# Launch VS Code
code

# Install Claude Extension
# In VS Code: Cmd+Shift+P → "Extensions: Install Extensions"
# Search for "Claude" by Anthropic
# Click Install
```

### Step 5: Configure MCP Servers

MCP (Model Context Protocol) bridges connect Claude Desktop to external tools.

#### Create Config Directory
```bash
mkdir -p ~/Library/Application\ Support/Claude
```

#### Copy Example Config
```bash
# Copy from this repo
cp claude_desktop_config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

#### Add Your API Keys

Edit the config file:
```bash
open ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Replace these placeholders:
- `YOUR_GITHUB_PAT_HERE` - [Create GitHub PAT](https://github.com/settings/tokens)
- `YOUR_NOTION_TOKEN_HERE` - [Get Notion Integration Token](https://www.notion.so/my-integrations)
- `YOUR_ZAPIER_API_KEY_HERE` - [Get Zapier API Key](https://zapier.com/app/settings/api)
- `YOUR_SUPABASE_PROJECT_REF` - From your [Supabase Dashboard](https://supabase.com/dashboard)

**Restart Claude Desktop** after updating the config.

### Step 6: Verify Setup

Test your installation:

```bash
# Check Claude Code
claude --version

# Check Homebrew
brew --version

# Check VS Code
code --version
```

In Claude Desktop:
1. Open a new conversation
2. Type: "Can you access my GitHub repos?"
3. Claude should respond confirming GitHub MCP access

---

## 🔧 How Claude Desktop Acts as Your Central Hub

Think of Claude Desktop as your **AI mission control**:

```
┌─────────────────────────────────────────┐
│         Claude Desktop (Hub)            │
│   • MCP Bridge Connections              │
│   • Unified AI Interface                │
│   • Cross-Tool Communication            │
└─────────────┬───────────────────────────┘
              │
       ┌──────┴──────┐
       │   MCP       │
       │  Bridges    │
       └──────┬──────┘
              │
    ┌─────────┼─────────┬─────────┐
    ▼         ▼         ▼         ▼
┌────────┐ ┌──────┐ ┌────────┐ ┌────────┐
│ GitHub │ │Notion│ │Supabase│ │ Zapier │
└────────┘ └──────┘ └────────┘ └────────┘
```

### What Claude Desktop Does

1. **Unified Access**: One interface to control multiple services
2. **Context Sharing**: Claude remembers context across all MCP connections
3. **Smart Routing**: Automatically uses the right tool for each task
4. **Memory Persistence**: Retains conversation history and learned patterns

### MCP Bridge Benefits

- **GitHub**: Create issues, review PRs, manage repos - all via chat
- **Notion**: Update documentation, query databases, create pages
- **Supabase**: Query databases, manage tables, run migrations
- **Zapier**: Trigger automations, connect to 5,000+ apps
- **Filesystem**: Access local files, create projects, manage code

---

## 🔗 How Claude Code, Extension, and Cowork Fit Together

These tools complement Claude Desktop for a complete workflow:

### Claude Code CLI
**For: Terminal-based development**

```bash
# Generate full features
claude "Add user authentication with NextAuth"

# Fix bugs
claude "Debug why the API is returning 500"

# Refactor code
claude "Refactor the payment flow to use Stripe"
```

**When to use:**
- Building features from scratch
- Complex multi-file changes
- Debugging production issues
- CI/CD integration

### Claude VS Code Extension
**For: In-editor assistance**

**When to use:**
- Quick code explanations
- Inline refactoring suggestions
- Documentation generation
- Code review while editing

**Keyboard shortcuts:**
- `Cmd+Shift+C` - Open Claude sidebar
- `Cmd+K` - Ask Claude about selection
- `Cmd+Shift+P` → "Claude: Explain" - Explain highlighted code

### Claude Cowork (Premium)
**For: Team collaboration**

**When to use:**
- Team-wide coding standards
- Shared skills and agents
- Multi-developer projects
- Enterprise workflows

**Setup:**
- [Join Claude Cowork Early Access](https://www.anthropic.com/cowork)
- Requires Claude Team or Enterprise plan

---

## 🍎 Mac-Specific Advantages

### Native Integration

1. **Apple Shortcuts**: Create custom shortcuts to launch Claude workflows
   ```
   Cmd+Shift+C → Open Claude Desktop
   Cmd+Option+C → New Claude Code session
   ```

2. **Spotlight Integration**: Type "claude" in Spotlight to launch instantly

3. **Raycast Integration**: Add Claude Desktop to Raycast for even faster access
   ```bash
   brew install --cask raycast
   # Add Claude Desktop as custom script
   ```

### Performance

- **Apple Silicon Optimization**: Claude runs natively on M-series chips
- **Fast Local Storage**: SSD speeds up filesystem MCP operations
- **Unified Memory**: Seamless memory sharing across apps

### Security

- **Keychain Integration**: Store API keys securely in macOS Keychain
- **Gatekeeper**: Apps are verified and sandboxed
- **FileVault**: Full-disk encryption protects your code

---

## 🎨 Recommended Workflow

Here's a battle-tested workflow for Mac:

### Morning Setup (5 minutes)
```bash
# 1. Open Claude Desktop (Cmd+Space, type "claude")
# 2. Check GitHub notifications via MCP
# 3. Review Notion todos

# In Terminal:
cd ~/Projects/your-project
claude "Review yesterday's changes and suggest today's priorities"
```

### Feature Development
```bash
# In Claude Desktop:
# "Create a GitHub issue for user profile feature with acceptance criteria"

# In Terminal (Claude Code):
cd ~/Projects/your-project
claude "Implement the user profile feature from issue #123"

# In VS Code:
# Review changes with Claude Extension
# Cmd+K on any function for explanations
```

### Code Review & Deploy
```bash
# In Claude Desktop:
# "Review the PR for user profiles and check for security issues"

# In Terminal:
git push
# Use Zapier MCP to trigger deployment notifications
```

---

## 📚 Essential Resources

### Official Documentation
- [Claude Desktop](https://claude.ai/desktop)
- [Claude Code Documentation](https://code.claude.ai/docs)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [Anthropic API Docs](https://docs.anthropic.com)

### Community Resources
- [Everything Claude Code (This Repo)](https://github.com/alfraido86-jpg/everything-claude-code)
- [MCP Server Directory](https://github.com/modelcontextprotocol/servers)
- [Claude Community Discord](https://discord.gg/anthropic)

### Learning Materials
- [The Shorthand Guide](../the-shortform-guide.md) - Read this first
- [The Longform Guide](../the-longform-guide.md) - Advanced topics
- [Stack Comparison](./stack-comparison.md) - Choose your tier

### Mac-Specific
- [Homebrew Documentation](https://docs.brew.sh)
- [Apple Shortcuts Gallery](https://support.apple.com/guide/shortcuts-mac)
- [Raycast Store](https://www.raycast.com/store)

---

## 🆘 Troubleshooting

### Claude Desktop Won't Start
```bash
# Check if already running
killall Claude

# Clear cache
rm -rf ~/Library/Caches/com.anthropic.claude

# Reinstall
brew reinstall --cask claude
```

### MCP Servers Not Working
```bash
# Verify config location
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Check JSON syntax
plutil -lint ~/Library/Application\ Support/Claude/claude_desktop_config.json

# View logs
tail -f ~/Library/Logs/Claude/mcp-*.log
```

### Claude Code CLI Issues
```bash
# Reinstall
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code

# Clear cache
rm -rf ~/.claude/cache

# Verify Node.js version (requires 18+)
node --version
```

### VS Code Extension Not Loading
```bash
# Reinstall VS Code
brew reinstall --cask visual-studio-code

# Clear extension cache
rm -rf ~/.vscode/extensions/anthropic.claude-*

# Reinstall extension via VS Code UI
```

---

## 🔐 Security Best Practices

### API Key Management

**DO:**
- ✅ Use environment variables for sensitive keys
- ✅ Store in macOS Keychain when possible
- ✅ Rotate keys every 90 days
- ✅ Use separate keys for dev/staging/prod

**DON'T:**
- ❌ Commit API keys to git repos
- ❌ Share keys via Slack/email
- ❌ Use production keys in development
- ❌ Store keys in plain text files

### Example: Using Keychain
```bash
# Store GitHub PAT in Keychain
security add-generic-password -a "$USER" -s "github-pat" -w "ghp_your_token_here"

# Retrieve from Keychain
security find-generic-password -a "$USER" -s "github-pat" -w
```

### Filesystem MCP Security

The filesystem MCP only has access to directories you specify. Keep it restricted:

```json
{
  "filesystem": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/Users/yourname/Projects",
      "/Users/yourname/Documents/notes"
    ]
  }
}
```

**Never give access to:**
- ❌ `/` (root directory)
- ❌ `~/.ssh` (SSH keys)
- ❌ `~/Library` (system configs)
- ❌ `/System` (macOS system files)

---

## 🎯 Next Steps

Now that you're set up:

1. **Explore the guides**: Read [the-shortform-guide.md](../the-shortform-guide.md)
2. **Try the agents**: Check out [../agents](../agents)
3. **Install skills**: Browse [../skills](../skills)
4. **Configure rules**: Copy from [../rules](../rules)
5. **Join the community**: Star this repo and contribute back

---

## 💡 Pro Tips

### Speed Up Your Workflow

1. **Create Terminal Aliases**
   ```bash
   # Add to ~/.zshrc
   alias c="claude"
   alias ccd="open -a Claude"
   ```

2. **Use Alfred/Raycast Workflows**
   - Quick launch Claude Desktop
   - Search Claude conversations
   - Trigger common MCP actions

3. **Set Up Apple Shortcuts**
   - Create "New Claude Project" shortcut
   - Add to Services menu (right-click context)

### Optimize Context Window

Claude Desktop has a 200k token context window, but MCP servers consume tokens:

```
20 MCP servers = ~130k tokens used
10 MCP servers = ~70k tokens used
5 MCP servers = ~30k tokens used
```

**Strategy**: Use project-specific configs
```bash
# Create project override
mkdir -p .claude
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json .claude/

# Edit .claude/claude_desktop_config.json
# Only enable MCPs you need for this project
```

---

## ⚡ Quick Reference

### Essential Commands

```bash
# Claude Code
claude "your prompt here"
claude --help
claude --version

# Homebrew
brew update
brew upgrade
brew list --cask
brew cleanup

# Config Locations
~/Library/Application Support/Claude/  # Claude Desktop config
~/.claude/                              # Claude Code config
~/.vscode/extensions/                   # VS Code extensions
```

### Config File Locations

```
Claude Desktop:
  ~/Library/Application Support/Claude/claude_desktop_config.json

Claude Code:
  ~/.claude/settings.json
  ~/.claude/agents/
  ~/.claude/skills/
  ~/.claude/commands/

VS Code:
  ~/.vscode/extensions/anthropic.claude-*/
```

### Keyboard Shortcuts

```
Claude Desktop:
  Cmd+N         New conversation
  Cmd+K         Search conversations
  Cmd+,         Settings

VS Code:
  Cmd+Shift+C   Open Claude sidebar
  Cmd+K         Ask Claude
  Cmd+Shift+P   Command palette
```

---

**Questions?** Open an issue on [GitHub](https://github.com/alfraido86-jpg/everything-claude-code/issues) or check our [discussions](https://github.com/alfraido86-jpg/everything-claude-code/discussions).

**Ready to level up?** Check out [stack-comparison.md](./stack-comparison.md) to see which tier fits your workflow best.
