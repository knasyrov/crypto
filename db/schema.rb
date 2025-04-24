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

ActiveRecord::Schema[7.2].define(version: 2025_04_23_044754) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "eid"
    t.decimal "balance"
    t.string "path"
    t.integer "direction"
    t.string "wif"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "in_value"
    t.string "in_addr"
    t.string "out_addr"
    t.string "change_addr"
    t.decimal "fee_value"
    t.string "txid"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
