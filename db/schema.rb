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

ActiveRecord::Schema[7.2].define(version: 2025_04_25_101014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", primary_key: "eid", id: :string, force: :cascade do |t|
    t.decimal "balance", default: "0.0"
    t.string "path"
    t.integer "direction"
    t.string "wif"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wif"], name: "index_addresses_on_wif"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "in_value"
    t.string "in_addr", null: false
    t.string "out_addr", null: false
    t.string "change_addr"
    t.decimal "fee_value"
    t.string "txid"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "hex"
  end
end
