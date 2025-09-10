# MCP Host on Rails

> **Warning**: This is a demonstration project created for educational purposes. Use at your own risk in production environments.

A Rails 8 application demonstrating Model Context Protocol (MCP) integration, created for the presentation "Making Rails AI-Native with the Model Context Protocol" at **EuRuKo 2025**.

This project showcases how to build an MCP Host implementation in Ruby on Rails using the [`ruby-mcp-client`](https://github.com/simonx1/ruby-mcp-client) gem, enabling seamless integration between AI language models and external tools through the standardized MCP protocol.

## What is MCP?

The Model Context Protocol (MCP) is an open standard that enables AI applications to securely connect to external tools and data sources. This Rails application acts as an MCP Host, orchestrating conversations between users, AI models (OpenAI), and MCP-compatible tools.

## Features

- **Interactive AI Chat Interface**: Clean, responsive chat UI built with Turbo and Stimulus
- **MCP Tool Integration**: Dynamic tool discovery and execution from MCP servers
- **Tool Call Confirmation Workflow**: All tool executions require explicit user approval for security
- **Multi-Server Support**: Connect to multiple MCP servers simultaneously
- **Session Management**: Persistent conversation state with secure session handling
- **Real-time Updates**: Turbo-powered real-time UI updates without page refreshes
- **Database-Backed Configuration**: Manage MCP server connections through web interface

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
- Rails 8.0.2
- SQLite3
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/mcp-host-on-rails.git
   cd mcp-host-on-rails
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   echo "OPENAI_API_KEY=your_openai_api_key_here" >> .env
   ```

4. **Set up the database**
   ```bash
   bin/rails db:migrate
   ```

5. **Start the development server**
   ```bash
   bin/dev  # Starts both Rails server and Tailwind CSS watcher
   ```

The application will be available at `http://localhost:3030`

## Development

### Code Quality

```bash
# Run linter (RuboCop)
bundle exec rubocop

# Run security scanner
bundle exec brakeman
```

### Database Operations

```bash
# Run migrations
bin/rails db:migrate
```

## Key Dependencies

- **[rails](https://rubyonrails.org/)** (~> 8.0.2): Web application framework
- **[ruby-openai](https://github.com/alexrudall/ruby-openai)**: OpenAI API integration
- **[ruby-mcp-client](https://github.com/simonx1/ruby-mcp-client)**: MCP protocol client
- **[tailwindcss-rails](https://github.com/rails/tailwindcss-rails)**: CSS styling framework
- **[turbo-rails](https://turbo.hotwired.dev/)**: SPA-like page acceleration
- **[stimulus-rails](https://stimulus.hotwired.dev/)**: Modest JavaScript framework

## User Workflow

1. **Start Conversation**: Navigate to root path to begin new chat session
2. **View Available Tools**: Visit toolbox to see connected MCP tools
3. **Chat with AI**: Send messages that may trigger tool usage
4. **Tool Confirmation**: When AI wants to use tools, approve or decline each call
5. **Tool Execution**: Approved tools execute via MCP servers
6. **Response Integration**: Tool results are fed back to AI for final response

## Security Features

- **Tool Call Confirmation**: Every tool execution requires explicit user approval
- **Session-based Isolation**: Each chat session is isolated with secure UUIDs
- **Input Sanitization**: All user inputs are properly sanitized
- **CSRF Protection**: Standard Rails CSRF protection enabled
- **Secure Headers**: Security headers configured for production deployment

## Project Structure

```
app/
├── controllers/
│   ├── mcp_chat_controller.rb      # Main chat orchestration
│   └── mcp_servers_controller.rb   # Server configuration
├── models/
│   ├── mcp_chat.rb                 # Conversation management
│   ├── mcp_server.rb              # Server configuration
│   └── message.rb                  # Message storage
└── views/
    ├── mcp_chat/                   # Chat interface templates
    └── mcp_servers/               # Server management UI

config/routes.rb                    # Application routing
db/migrate/                         # Database migrations
```

## ruby-mcp-client Gem Integration

This application uses the **HTTP** transport configuration for MCP communication:

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

The gem provides multiple transport types (stdio, SSE, HTTP, Streamable HTTP) and seamless integration with AI services through built-in tool format converters.

## Contributing

This is a demonstration project for EuRuKo 2025. While primarily educational, contributions are welcome:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## About EuRuKo 2025

This application was created as a demonstration for the presentation "Making Rails AI-Native with the Model Context Protocol" at EuRuKo 2025. The project showcases practical implementation patterns for integrating MCP into Ruby on Rails applications, making them AI-native while maintaining security and user control.

## Disclaimer

This is a toy/pet project created for educational and demonstration purposes. While it implements security best practices, it has not undergone extensive production testing. Use at your own risk in production environments.

---

For questions or feedback about this implementation, feel free to open an issue or reach out during EuRuKo 2025!
