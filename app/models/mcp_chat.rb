class McpChat < ApplicationRecord
  def add_message(message)
    self.messages ||= []
    self.messages << message.to_h
  end

  def raw_messages
    self.messages || []
  end

  def ui_messages
    raw_messages.map do |message|
      next if message["role"] == "assistant" && message["content"].blank?
      next if message["role"] == "system"

      if message["role"] == "tool"
        message["content"] = "Calling tool <br><pre>#{message["function_name"]}#{(message["function_arguments"] || []).map { |k, v| "\n  #{k} => #{v}" }.join("") }</pre>"
      end

      message
    end.compact
  end

  def has_pending_tool_call?
    last_message = raw_messages.last
    last_message&.dig("role") == "assistant" &&
    last_message&.dig("tool_calls")&.any?
  end

  def pending_tool_confirmation?
    has_pending_tool_call?
  end

  def pending_tool_call
    return nil unless has_pending_tool_call?
    raw_messages.last&.dig("tool_calls")&.first
  end

  def approve_single_tool!
    update!(tool_confirmation_state: "YES")
  end

  def reset_confirmation_state!
    update!(tool_confirmation_state: nil)
  end
end
