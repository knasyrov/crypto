class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses, primary_key: :eid do |t|
      t.string :eid
      t.decimal :balance
      t.string :path
      t.integer :direction 
      t.string :wif

      t.timestamps
      t.index :wif
    end
  end
end
