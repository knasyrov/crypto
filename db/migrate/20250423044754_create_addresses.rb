class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses, id: false, force: true do |t|
      t.string :eid, primary_key: true
      t.decimal :balance, default: 0
      t.string :path
      t.integer :direction
      t.string :wif

      t.timestamps
      t.index :wif
    end
  end
end
