class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.decimal :in_value, precision: 16, scale: 8
      t.string :in_addr
      t.string :out_addr
      t.string :change_addr
      t.decimal :fee_value, precision: 16, scale: 8
      t.decimal :fee_percent
      t.string :wallet
      t.timestamps
    end
  end
end
