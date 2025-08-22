require "mcp_client"

class McpChatController < ApplicationController
  skip_before_action :verify_authenticity_token

  def toolbox
    @tools ||= mcp_client.list_tools
  end

  def new
    session["mcp_chat_id"] = SecureRandom.uuid
    @mcp_chat_id = session["mcp_chat_id"]
  end

  def show
    mcp_chat or redirect_to "/mcp_chat/new"
  end

  def chat
    unless session["mcp_chat_id"]
      redirect_to "/mcp_chat/new"
      return
    end

    # If we have a pending tool call, execute it based on confirmation state
    if mcp_chat.has_pending_tool_call?
      if mcp_chat.tool_confirmation_state == "YES"
        execute_pending_tool_and_continue
        mcp_chat.reset_confirmation_state!
        redirect_to "/mcp_chat/"
        return
      end
      # If no confirmation state set, fall through to show confirmation UI
    else
      # Regular chat flow - add user message and get LLM response
      mcp_chat.add_message(
        "role" => "user",
        "content" => params[:prompt]
      )

      get_llm_response_and_handle_tools
    end

    redirect_to "/mcp_chat/"
  end

  def confirm_tool_yes
    mcp_chat.approve_single_tool!
    execute_pending_tool_and_continue
    mcp_chat.reset_confirmation_state!
    redirect_to "/mcp_chat/"
  end

  def confirm_tool_no
    # Add a user message indicating tool call was declined
    tool_call = mcp_chat.pending_tool_call
    tool_name = tool_call&.dig("function", "name")

    mcp_chat.add_message(
      "role" => "user",
      "content" => "I decline the tool call: #{tool_name}"
    )

    mcp_chat.reset_confirmation_state!
    # Remove the pending tool call message
    messages = mcp_chat.raw_messages
    if messages[-2]&.dig("role") == "assistant" && messages[-2]&.dig("tool_calls")
      messages.delete_at(-2)  # Remove the assistant message with tool calls (now second to last)
      mcp_chat.update!(messages: messages)
    end

    mcp_chat.save!
    redirect_to "/mcp_chat/"
  end

  private

  def get_llm_response_and_handle_tools
    response = openai_client.chat(
      parameters: {
        model: "gpt-4.1-mini",
        messages: mcp_chat.raw_messages,
        temperature: 0.7,
        tools: tools,
        tool_choice: "auto"
      }
    )

    assistant_message = response.dig("choices", 0, "message")
    tool_call_definitions = assistant_message["tool_calls"] || []

    if tool_call_definitions.any?
      # Pause here for confirmation - add assistant message with only the first tool call
      first_tool_call = tool_call_definitions.first
      mcp_chat.add_message({
        "role" => "assistant",
        "tool_calls" => [ first_tool_call ]
      })
      mcp_chat.save!
      return
    end

    # No tools - add assistant message and save
    mcp_chat.add_message(assistant_message)
    mcp_chat.save!
  end

  def execute_pending_tool_and_continue
    tool_call_definition = mcp_chat.pending_tool_call
    return unless tool_call_definition

    # Get the last assistant message and modify it to only contain the confirmed tool call
    messages = mcp_chat.raw_messages
    last_message = messages.last

    if last_message&.dig("role") == "assistant" && last_message&.dig("tool_calls")&.any?
      # Replace the assistant message with only the confirmed tool call
      messages[-1] = {
        "role" => "assistant",
        "tool_calls" => [ tool_call_definition ]
      }
      mcp_chat.update!(messages: messages)
    end

    execute_single_tool(tool_call_definition)
    mcp_chat.save!

    # Continue with LLM conversation
    continue_llm_conversation
  end

  def execute_single_tool(tool_call_definition)
    function_name = tool_call_definition.dig("function", "name")
    function_arguments = JSON.parse(tool_call_definition.dig("function", "arguments"))

    tool_call_result = mcp_client.call_tool(function_name, function_arguments)

    mcp_chat.add_message(
      "role" => "tool",
      "tool_call_id" => tool_call_definition["id"],
      "function_name" => function_name,
      "function_arguments" => function_arguments,
      "content" => tool_call_result.to_json
    )
  end

  def continue_llm_conversation
    response = openai_client.chat(
      parameters: {
        model: "gpt-4.1-mini",
        messages: mcp_chat.raw_messages,
        tools: tools,
        tool_choice: "auto",
        temperature: 0.7
      }
    )

    assistant_message = response.dig("choices", 0, "message")
    tool_call_definitions = assistant_message["tool_calls"] || []

    if tool_call_definitions.any?
      # Another tool call - add message with only the first tool call and pause for confirmation
      first_tool_call = tool_call_definitions.first
      mcp_chat.add_message({
        "role" => "assistant",
        "tool_calls" => [ first_tool_call ]
      })
      mcp_chat.save!
      return
    end

    # No more tools - add final assistant message
    mcp_chat.add_message(assistant_message)
    mcp_chat.save!
  end

  def mcp_client
    @mcp_client ||= begin
      servers = McpServer.ordered
      
      # Fallback to environment variable if no servers configured
      if servers.empty?
        fallback_url = ENV.fetch("MCP_SERVER_URL", "http://localhost:3000/mcp")
        configs = [MCPClient.streamable_http_config(
          base_url: fallback_url,
          read_timeout: 60,     # Timeout in seconds for HTTP requests
          retries: 3,           # Number of retry attempts on transient errors
          retry_backoff: 2,     # Base delay in seconds for exponential backoff
          logger: logger        # Optional logger for debugging requests
        )]
      else
        configs = servers.map do |server|
          MCPClient.streamable_http_config(
            base_url: server.url,
            read_timeout: 60,     # Timeout in seconds for HTTP requests
            retries: 3,           # Number of retry attempts on transient errors
            retry_backoff: 2,     # Base delay in seconds for exponential backoff
            logger: logger        # Optional logger for debugging requests
          )
        end
      end
      
      MCPClient.create_client(mcp_server_configs: configs)
    end
  end

  def tools
    @tools ||= mcp_client.to_openai_tools
  end

  def openai_client
    @openai_client ||= OpenAI::Client.new # (access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def mcp_chat
    return @mcp_chat if @mcp_chat

    @mcp_chat = McpChat.find_by(mcp_chat_id: session["mcp_chat_id"])
    unless @mcp_chat
      @mcp_chat = McpChat.new(mcp_chat_id: session["mcp_chat_id"])
      @mcp_chat.add_message(
        "role" => "system",
        "content" => "You are a helpful assistant"
      )
    end

    @mcp_chat
  end
end
