$vscode = Get-Content .vscode/mcp.json -Raw | ConvertFrom-Json
$antigravity = @{ mcpServers = $vscode.servers }
$antigravity | ConvertTo-Json -Depth 10 | Set-Content .agents/mcp_config.json