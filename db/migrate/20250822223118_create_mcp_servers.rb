class CreateMcpServers < ActiveRecord::Migration[8.0]
  def change
    create_table :mcp_servers do |t|
      t.string :name, null: false
      t.string :url, null: false

      t.timestamps
    end
    add_index :mcp_servers, :name, unique: true
    add_index :mcp_servers, :created_at
  end
end
