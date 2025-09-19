# MCP Host on Rails

A Rails 8 application implementing a Model Context Protocol (MCP) host with chat interface, tool confirmation mechanics, and persistent conversation management. This project demonstrates practical MCP integration using the `ruby-mcp-client` gem to create a conversational AI assistant with secure access to external tools.

**Featured at EuRuKo 2025**: https://2025.euruko.org/

This application showcases how to build an MCP Host implementation in Ruby on Rails, bridging the gap between Large Language Models and external tools through the standardized Model Context Protocol.

## What is MCP?

The Model Context Protocol (MCP) is an open standard that enables AI applications to securely connect to external tools and data sources. This Rails application acts as an MCP Host, orchestrating conversations between users, AI models (OpenAI), and MCP-compatible tools.

## Key Features

- **Interactive Chat Interface**: Clean, modern chat UI with message persistence
- **Tool Confirmation Workflow**: Security-first approach requiring user approval for all tool executions
- **Multi-Server Support**: Connect to multiple MCP servers simultaneously via web interface
- **Session Management**: Session-based chat instances with UUIDs
- **Database Persistence**: All conversations stored in SQLite with JSON message history
- **Dynamic Tool Loading**: Tools are discovered and loaded dynamically from configured MCP servers
- **Real-time Updates**: Turbo-powered UI updates without page refreshes
- **Graceful Degradation**: Functions as standard AI assistant when no MCP servers are configured

## Architecture

### Core Components

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   User Input    │───▶│     Rails    │───▶│   OpenAI API    │
│                 │    │  Application │    │                 │
└─────────────────┘    └──────────────┘    └─────────────────┘
                              │                       │
                              ▼                       ▼
                       ┌──────────────┐    ┌─────────────────┐
                       │     MCP      │◀───│  Tool Calls &   │
                       │   Servers    │    │   Responses     │
                       └──────────────┘    └─────────────────┘
```

### Key Models

- **`McpChat`**: Manages conversation state and message history
- **`McpServer`**: Stores MCP server configurations
- **`Message`**: Individual message domain model - not persisted

### Key Controllers

- **`McpChatController`**: Orchestrates AI conversations and tool execution workflow
- **`McpServersController`**: Manages MCP server configuration

## Getting Started

### Prerequisites

- Ruby 3.4.2
- Rails 8
- SQLite
- OpenAI API key

### Installation

1. **Clone the repository**:
```bash
git clone <repository-url>
cd mcp-host-on-rails
```

2. **Install dependencies**:
```bash
bundle install
```

3. **Set up the database**:
```bash
bin/rails db:migrate
```

4. **Configure environment variables**:
```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

5. **Start the development server**:
```bash
bin/dev
```

The application will be available at `http://localhost:3030`

## Usage

### Starting a New Chat

1. Visit the application homepage
2. If no active chat exists, you'll be redirected to create a new chat session
3. Enter your message and start conversing

### Tool Confirmation Workflow

When the AI assistant requests to use a tool:

1. **Tool Request**: Chat pauses and displays tool confirmation dialog
2. **Review Details**: Tool name, description, and parameters are shown
3. **User Decision**: Click "Allow" to execute or "Deny" to decline
4. **Execution**: If approved, tool runs and results are integrated into conversation
5. **Continuation**: Chat resumes with tool results incorporated

### MCP Server Configuration

1. Navigate to `/mcp_servers` in the application
2. Add MCP servers by providing:
   - **Name**: Descriptive identifier for the server
   - **URL**: HTTP/HTTPS endpoint (must support MCP HTTP transport)

**Important**: All MCP servers must use HTTP/HTTPS transport. When no servers are configured, the application functions as a standard AI chat assistant without tool capabilities.

### Available Endpoints

- `/` - Main chat interface
- `/mcp_chat/new` - Initialize new chat session
- `/mcp_chat/toolbox` - View available MCP tools
- `/mcp_servers` - Manage MCP server configurations

### Message Flow

1. **User Input** → Chat controller receives user message
2. **LLM Processing** → OpenAI processes message with available tool descriptions
3. **Tool Request** → If LLM requests tool use, user sees confirmation dialog
4. **Tool Execution** → Upon approval, tool is called via MCP client
5. **Response Integration** → Tool results are sent back to LLM for final response
6. **Display** → Complete conversation with tool interactions shown to user

### MCP Integration

The application uses the `ruby-mcp-client` gem to communicate with MCP servers via HTTP transport:

```ruby
@mcp_client ||= MCPClient.create_client(
  mcp_server_configs: [
    MCPClient.http_config(
      base_url: "http://localhost:3000/mcp",
      read_timeout: 60,
      retries: 3,
      retry_backoff: 2
    )
  ]
)
```

### Database Schema

**mcp_chats table:**
- `id` - Primary key
- `mcp_chat_id` - Session identifier (UUID)
- `messages` - JSON array of conversation messages
- `tool_confirmation_state` - Current tool confirmation status
- `timestamps` - Created/updated timestamps

**mcp_servers table:**
- `id` - Primary key
- `name` - Server identifier (unique)
- `url` - Server endpoint URL
- `timestamps` - Created/updated timestamps

### Message Format

Messages are stored as JSON objects with OpenAI-compatible structure:

```json
{
  "role": "user|assistant|tool|system",
  "content": "Message content",
  "tool_calls": [...],  // For assistant messages requesting tools
  "function_name": "...", // For tool response messages
  "function_arguments": {...}
}
```

## Contributing

This project was created for demonstration purposes at EuRuKo 2025. While primarily educational, contributions are welcome for:

- Bug fixes and improvements
- Additional MCP transport support
- UI/UX enhancements
- Documentation improvements
- Test coverage expansion

## Acknowledgments

- **EuRuKo 2025** - For providing the platform to showcase this project
- **ruby-mcp-client** - By simonx1, enabling Ruby MCP Client
- **Model Context Protocol** - Open standard for AI-tool integration
- **Ruby on Rails Community** - For the excellent framework and ecosystem

## Related Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [ruby-mcp-client GitHub Repository](https://github.com/simonx1/ruby-mcp-client)
- [EuRuKo 2025 Conference](https://2025.euruko.org/)
- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
