class Message
  attr_accessor :content, :role

  def initialize(message_hash = nil)
    if message_hash
      @role = message_hash["role"] || message_hash[:role]
      @content = message_hash["content"] || message_hash[:content]
    end
  end
end
