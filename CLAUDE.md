# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Server Management
```bash
# Start development server with CSS watching
bin/dev

# Or start individual processes
bin/rails server    # Web server
bin/rails tailwindcss:watch    # CSS watcher
```

### Database Operations
```bash
# Run migrations
bin/rails db:migrate

# Reset and seed database
bin/rails db:reset

# Create test database
bin/rails db:test:prepare
```

### Testing
```bash
# Run all tests
bin/rails test

# Run system tests
bin/rails test:system

# Run specific test file
bin/rails test test/models/mcp_chat_test.rb
```

### Code Quality
```bash
# Run linter (Rubocop)
bundle exec rubocop

# Run security scanner
bundle exec brakeman
```

## Architecture Overview

This is a Rails 8 application that implements an MCP (Model Context Protocol) chat interface. The core architecture consists of:

### Key Components

1. **McpChat Model** (`app/models/mcp_chat.rb`):
   - Stores conversation state with JSON message history
   - Handles tool call confirmations and state management
   - Provides UI-friendly message formatting

2. **McpChatController** (`app/controllers/mcp_chat_controller.rb`):
   - Orchestrates conversations between user, OpenAI, and MCP tools
   - Implements tool call confirmation workflow
   - Manages session-based chat instances

3. **MCP Integration**:
   - Uses `ruby-mcp-client` gem for MCP protocol communication
   - Configured to connect to local MCP server at `localhost:3000/mcp`
   - Tools are dynamically loaded and converted to OpenAI format

### Key Patterns

- **Tool Call Workflow**: All tool calls require user confirmation before execution
- **Message Flow**: User → OpenAI → Tool Confirmation → MCP Execution → OpenAI → User  
- **Session Management**: Chat instances are tied to secure session UUIDs
- **State Persistence**: All conversation state stored in SQLite database

### Dependencies

- **Rails 8**: Core framework
- **ruby-openai**: OpenAI API integration  
- **ruby-mcp-client**: MCP protocol client
- **Tailwind CSS**: UI styling
- **Turbo/Stimulus**: Frontend interactions

### Configuration

- OpenAI API key required via `OPENAI_API_KEY` environment variable
- MCP server expected at `http://localhost:3000/mcp`
- SQLite database for development/test
- Tailwind CSS with custom builds

### Routes Structure

- `/` - Main chat interface
- `/mcp_chat/new` - Initialize new chat session
- `/mcp_chat/toolbox` - View available MCP tools
- Tool confirmation endpoints for approve/decline workflow

## ruby-mcp-client Gem Reference

### Overview

The `ruby-mcp-client` gem (v1.x, MIT License) by simonx1 provides a Ruby implementation of the Model Context Protocol (MCP) client. This gem is the core dependency enabling MCP tool integration in this application.

**Repository**: https://github.com/simonx1/ruby-mcp-client  
**Community**: 75+ stars, actively maintained since April 2025

### Key Features

- **Multiple Transport Support**: stdio, SSE, HTTP, and Streamable HTTP
- **Multi-Server Connections**: Connect to multiple MCP servers simultaneously  
- **AI Service Integration**: Built-in converters for OpenAI, Anthropic, and Google formats
- **OAuth 2.1 Support**: Enterprise-grade authentication
- **Thread-Safe Operations**: Concurrent tool execution support

### Transport Types

1. **stdio**: Local process communication
   ```ruby
   MCPClient.stdio_config(
     command: 'npx -y @modelcontextprotocol/server-filesystem /path',
     name: 'filesystem_server'
   )
   ```

2. **SSE (Server-Sent Events)**: Remote streaming
   ```ruby
   MCPClient.sse_config(
     base_url: 'https://api.example.com/sse',
     headers: { 'Authorization' => 'Bearer TOKEN' }
   )
   ```

3. **HTTP**: Standard request/response
   ```ruby
   MCPClient.http_config(
     base_url: 'https://api.example.com',
     headers: { 'API-Key' => 'key' }
   )
   ```

4. **Streamable HTTP**: HTTP POST with SSE responses
   ```ruby
   MCPClient.streamable_http_config(
     base_url: 'http://localhost:3000/mcp',
     read_timeout: 60,
     retries: 3,
     retry_backoff: 2
   )
   ```

### Core API Methods

#### Client Creation
```ruby
client = MCPClient.create_client(
  mcp_server_configs: [config1, config2, ...]
)
```

#### Tool Operations
```ruby
# List all available tools
tools = client.list_tools

# Execute single tool
result = client.call_tool('tool_name', { param: 'value' })

# Execute multiple tools
results = client.call_tools([
  { name: 'tool1', args: { param: 'value1' } },
  { name: 'tool2', args: { param: 'value2' } }
])

# Streaming tool execution
client.call_tool_streaming('tool_name', args) do |chunk|
  # Process streaming response
end
```

#### Discovery Methods
```ruby
# Find specific server
server = client.find_server('server_name')

# Find tools matching criteria
matching_tools = client.find_tools(name: /pattern/)
```

#### AI Service Integration
```ruby
# Convert tools for different AI services
openai_tools = client.to_openai_tools
anthropic_tools = client.to_anthropic_tools  
google_tools = client.to_google_tools
```

### Configuration Options

- **Timeouts**: `read_timeout`, `write_timeout`
- **Retry Logic**: `retries`, `retry_backoff`
- **Logging**: Custom logger support
- **Authentication**: OAuth 2.1, API keys, custom headers
- **Connection Pooling**: Automatic connection management

### Current Implementation in This App

The app uses **Streamable HTTP** transport configured in `app/controllers/mcp_chat_controller.rb:177-189`:

```ruby
@mcp_client ||= MCPClient.create_client(
  mcp_server_configs: [
    MCPClient.streamable_http_config(
      base_url: "http://localhost:3000/mcp",
      read_timeout: 60,
      retries: 3,
      retry_backoff: 2,
      logger: logger
    )
  ]
)
```

### Usage Patterns in This App

1. **Tool Discovery**: `mcp_client.list_tools` for toolbox display
2. **OpenAI Integration**: `mcp_client.to_openai_tools` for LLM tool descriptions  
3. **Tool Execution**: `mcp_client.call_tool(name, args)` after user confirmation
4. **Error Handling**: Built-in retry logic with exponential backoff
- rails server runs at 3030 port