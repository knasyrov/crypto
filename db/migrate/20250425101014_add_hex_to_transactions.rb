class AddHexToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :hex, :text
  end
end
