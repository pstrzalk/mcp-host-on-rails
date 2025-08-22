# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_22_223118) do
  create_table "mcp_chats", force: :cascade do |t|
    t.string "tool_confirmation_state"
    t.string "mcp_chat_id"
    t.json "messages", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mcp_servers", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_mcp_servers_on_created_at"
    t.index ["name"], name: "index_mcp_servers_on_name", unique: true
  end
end
