class CreateMcpChats < ActiveRecord::Migration[8.0]
  def change
    create_table :mcp_chats do |t|
      t.string :tool_confirmation_state

      t.string :mcp_chat_id
      t.json :messages, default: []

      t.timestamps
    end
  end
end
