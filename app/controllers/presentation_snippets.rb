messages = []
messages << add_system_message("You are a helpful assistant")
messages << add_user_message("Book me a romantic trip")


class McpChatController < ApplicationController
  def chat
    # 1. Instantiate MCP Client
    # 2. Load MCP Tools
    # 3. Send Prompt + Tools to LLM
    # 4. Receive response and call tools
    # 5. Present the answer
  end
end



# ---
require "mcp_client"

config = MCPClient.streamable_http_config(
  base_url: "http://localhost:3000/mcp"
)

mcp_client = MCPClient.create_client(
  mcp_server_configs: [ config ]
)

mcp_tools = mcp_client.list_tools



# ---
tools = mcp_client.list_tools

tools.first.name
=> "post-update-tool"

tools.first.description
=> "Update a Post entity of a given ID"

tools.first.schema
=> {
     "type" => "object",
     "properties" => {
       "id"    => {"type" => "integer"},
       "title" => {"type" => "string"},
       "body"  => {"type" => "string"}
     },
     "required" => ["id"]
   }

post_create_tool = tools.first
# albo post_create_tool = tools.fifth

mcp_client.list_tools.count
=> 10
# no albo 11
#
#
#


messages = [
  { "role" => "system", "content" => "You are a helpful assistant" },
  { "role" => "user",   "content" => "Write a post about EuRuKo" }
]

response = OpenAI::Client.new.chat(
  parameters: {
    model: "gpt-4.1-mini",
    messages: messages,
    tools: tools
  }
)



## SHOW WHAT WE GET FROM THIS#

assistant_message = response.dig("choices", 0, "message")
messages << assistant_message

tool_call_definitions = extract_tool_calls(assistant_message)
tool_call_definitions.each do |tool_call_definition|
  function_name, function_arguments = parse(tool_call_definition)

  tool_call_result = mcp_client.call_tool(function_name, function_arguments)
  messages << tool_call_result
end

render and return if tool_call_definitions.empty?
