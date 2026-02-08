# MCP Packages Directory

This directory should contain the following pinned .tgz tarballs for offline MCP server installation:

## Required Packages

1. **@modelcontextprotocol/server-filesystem**
   - Pattern: `modelcontextprotocol-server-filesystem-*.tgz`
   - Example: `modelcontextprotocol-server-filesystem-0.5.1.tgz`

2. **@modelcontextprotocol/server-memory**
   - Pattern: `modelcontextprotocol-server-memory-*.tgz`
   - Example: `modelcontextprotocol-server-memory-0.5.1.tgz`

3. **@anthropic-ai/claude-code**
   - Pattern: `anthropic-ai-claude-code-*.tgz`
   - Example: `anthropic-ai-claude-code-1.0.0.tgz`

## How to Obtain .tgz Files

You can create these tarballs from npm packages using:

```bash
npm pack @modelcontextprotocol/server-filesystem
npm pack @modelcontextprotocol/server-memory
npm pack @anthropic-ai/claude-code
```

Then move the generated `.tgz` files to this directory.

## Directory Structure

```
scripts/
└── mcp_packages/
    ├── README.md (this file)
    ├── modelcontextprotocol-server-filesystem-0.5.1.tgz
    ├── modelcontextprotocol-server-memory-0.5.1.tgz
    └── anthropic-ai-claude-code-1.0.0.tgz
```

## Notes

- The `Rebuild-ClaudeStack.ps1` script requires EXACTLY ONE matching tarball for each package
- The script will fail fast if any required tarball is missing
- Package names follow npm's tarball naming convention (scoped packages have `@` replaced with organization name)
