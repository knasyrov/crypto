class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.decimal :in_value
      t.string :in_addr, null: false
      t.string :out_addr, null: false
      t.string :change_addr
      t.decimal :fee_value
      t.string :txid
      t.integer :state, default: 0
      t.timestamps
    end
  end
end