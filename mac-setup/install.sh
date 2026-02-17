#!/bin/bash

################################################################################
# Premium Mac AI Stack Installer
# 
# This script installs and configures the complete Claude AI development stack
# on macOS including Claude Desktop, Claude Code CLI, VS Code + Extension,
# and sets up MCP server configurations.
#
# Safe to re-run - all operations are idempotent
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
CLAUDE_CODE_CONFIG_DIR="$HOME/.claude"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

################################################################################
# Pre-flight Checks
################################################################################

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is for macOS only"
        exit 1
    fi
    print_success "Running on macOS"
}

check_admin() {
    if ! sudo -n true 2>/dev/null; then
        print_info "This script requires sudo access for some installations"
        sudo -v
    fi
}

################################################################################
# Homebrew Installation
################################################################################

install_homebrew() {
    print_header "Homebrew Package Manager"
    
    if command_exists brew; then
        print_success "Homebrew already installed"
        BREW_VERSION=$(brew --version | head -n 1)
        print_info "$BREW_VERSION"
        
        print_info "Updating Homebrew..."
        brew update || print_error "Failed to update Homebrew (non-fatal)"
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH based on chip type
        if [[ $(uname -m) == "arm64" ]]; then
            # Apple Silicon
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully"
    fi
}

################################################################################
# Claude Desktop Installation
################################################################################

install_claude_desktop() {
    print_header "Claude Desktop"
    
    if [[ -d "/Applications/Claude.app" ]]; then
        print_success "Claude Desktop already installed"
        print_info "Location: /Applications/Claude.app"
    else
        print_info "Installing Claude Desktop..."
        brew install --cask claude || {
            print_error "Failed to install Claude Desktop via Homebrew"
            print_info "Please install manually from: https://claude.ai/download"
            return 1
        }
        print_success "Claude Desktop installed successfully"
    fi
}

################################################################################
# Claude Code CLI Installation
################################################################################

install_claude_code() {
    print_header "Claude Code CLI"
    
    if command_exists claude; then
        print_success "Claude Code already installed"
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        print_info "Version: $CLAUDE_VERSION"
    else
        print_info "Installing Claude Code CLI..."
        
        # Check if npm is available
        if ! command_exists npm; then
            print_info "Node.js/npm not found. Installing via Homebrew..."
            brew install node
        fi
        
        print_info "Installing @anthropic-ai/claude-code globally..."
        npm install -g @anthropic-ai/claude-code || {
            print_error "Failed to install Claude Code CLI"
            print_info "You may need to install it manually: npm install -g @anthropic-ai/claude-code"
            return 1
        }
        
        print_success "Claude Code CLI installed successfully"
    fi
}

################################################################################
# VS Code + Extension Installation
################################################################################

install_vscode() {
    print_header "Visual Studio Code"
    
    if command_exists code; then
        print_success "VS Code already installed"
        CODE_VERSION=$(code --version | head -n 1)
        print_info "Version: $CODE_VERSION"
    else
        print_info "Installing VS Code..."
        brew install --cask visual-studio-code || {
            print_error "Failed to install VS Code via Homebrew"
            print_info "Please install manually from: https://code.visualstudio.com"
            return 1
        }
        print_success "VS Code installed successfully"
        
        # Wait a moment for PATH to update
        sleep 2
    fi
    
    # Install Claude Extension
    print_info "Checking for Claude extension..."
    if command_exists code; then
        # Check if extension is installed
        if code --list-extensions | grep -q "Anthropic.claude"; then
            print_success "Claude extension already installed"
        else
            print_info "Installing Claude extension..."
            code --install-extension Anthropic.claude || {
                print_error "Failed to install Claude extension automatically"
                print_info "Please install manually: Open VS Code → Cmd+Shift+P → 'Extensions: Install Extensions' → Search 'Claude'"
            }
        fi
    else
        print_info "VS Code command-line tools not available yet"
        print_info "After VS Code opens, install Claude extension: Cmd+Shift+P → 'Extensions: Install Extensions' → Search 'Claude'"
    fi
}

################################################################################
# Configuration Setup
################################################################################

setup_config_directories() {
    print_header "Configuration Directories"
    
    # Claude Desktop config directory
    if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
        print_info "Creating Claude Desktop config directory..."
        mkdir -p "$CLAUDE_CONFIG_DIR"
        print_success "Created $CLAUDE_CONFIG_DIR"
    else
        print_success "Claude Desktop config directory exists"
    fi
    
    # Claude Code config directory
    if [[ ! -d "$CLAUDE_CODE_CONFIG_DIR" ]]; then
        print_info "Creating Claude Code config directory..."
        mkdir -p "$CLAUDE_CODE_CONFIG_DIR"
        print_success "Created $CLAUDE_CODE_CONFIG_DIR"
    else
        print_success "Claude Code config directory exists"
    fi
}

copy_config_files() {
    print_header "Configuration Files"
    
    CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    SOURCE_CONFIG="$SCRIPT_DIR/claude_desktop_config.json"
    
    if [[ -f "$CONFIG_FILE" ]]; then
        print_info "Config file already exists at: $CONFIG_FILE"
        echo ""
        read -p "Do you want to backup and replace it? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            print_info "Backing up to: $BACKUP_FILE"
            cp "$CONFIG_FILE" "$BACKUP_FILE"
            print_success "Backup created"
            
            print_info "Copying new config..."
            cp "$SOURCE_CONFIG" "$CONFIG_FILE"
            print_success "Config file updated"
        else
            print_info "Keeping existing config file"
        fi
    else
        print_info "Copying example config file..."
        cp "$SOURCE_CONFIG" "$CONFIG_FILE"
        print_success "Config file copied to: $CONFIG_FILE"
    fi
    
    echo ""
    print_info "⚠️  IMPORTANT: You need to edit the config file and add your API keys"
    print_info "Config location: $CONFIG_FILE"
    print_info "Run: open '$CONFIG_FILE'"
}

################################################################################
# Apple Shortcuts Setup
################################################################################

suggest_apple_shortcuts() {
    print_header "Apple Shortcuts Setup"
    
    print_info "You can create Apple Shortcuts for quick access to Claude:"
    echo ""
    echo "  1. Open Shortcuts.app"
    echo "  2. Click '+' to create a new shortcut"
    echo "  3. Add action: 'Open App'"
    echo "  4. Select 'Claude'"
    echo "  5. Name it 'Open Claude'"
    echo "  6. Go to Settings → Shortcuts → Add Keyboard Shortcut"
    echo "  7. Assign: Cmd+Shift+C"
    echo ""
    print_info "Suggested shortcuts:"
    echo "  • Cmd+Shift+C → Open Claude Desktop"
    echo "  • Cmd+Option+C → New Terminal → cd ~/Projects"
    echo ""
}

################################################################################
# Post-Install Instructions
################################################################################

show_next_steps() {
    print_header "Installation Complete! 🎉"
    
    echo -e "${GREEN}All components installed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. 📝 Configure API Keys"
    echo "   Edit: $CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    echo "   Run: open '$CLAUDE_CONFIG_DIR/claude_desktop_config.json'"
    echo ""
    echo "   Required API keys:"
    echo "   • GitHub Personal Access Token → https://github.com/settings/tokens"
    echo "   • Notion Integration Token → https://www.notion.so/my-integrations"
    echo "   • Supabase Project Ref → https://supabase.com/dashboard"
    echo ""
    echo "2. 🚀 Launch Claude Desktop"
    echo "   Press Cmd+Space, type 'claude', press Enter"
    echo "   Sign in with your Anthropic account"
    echo ""
    echo "3. ✅ Verify Installation"
    echo "   In Claude Desktop, type: 'Can you access my GitHub repos?'"
    echo "   Claude should confirm GitHub MCP access"
    echo ""
    echo "4. 📚 Read the Documentation"
    echo "   • Main guide: $SCRIPT_DIR/README.md"
    echo "   • Stack comparison: $SCRIPT_DIR/stack-comparison.md"
    echo ""
    echo "5. 💡 Pro Tips"
    echo "   • Create Apple Shortcuts for quick access (see above)"
    echo "   • Add terminal aliases: alias c='claude'"
    echo "   • Install Raycast for even faster launcher"
    echo ""
    echo -e "${BLUE}Need help? Check the troubleshooting section in README.md${NC}"
    echo ""
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    print_header "Premium Mac AI Stack Installer"
    echo "This script will install:"
    echo "  • Homebrew (if needed)"
    echo "  • Claude Desktop"
    echo "  • Claude Code CLI"
    echo "  • Visual Studio Code + Claude Extension"
    echo "  • Configuration files"
    echo ""
    echo "Safe to re-run - all operations are idempotent"
    echo ""
    read -p "Continue with installation? (Y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        check_macos
        check_admin
        
        install_homebrew
        install_claude_desktop
        install_claude_code
        install_vscode
        
        setup_config_directories
        copy_config_files
        
        suggest_apple_shortcuts
        show_next_steps
        
        print_success "Installation script completed!"
    else
        print_info "Installation cancelled"
        exit 0
    fi
}

# Run main installation
main "$@"
