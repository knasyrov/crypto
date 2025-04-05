class CreateCurrencies < ActiveRecord::Migration[7.2]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :key

      t.timestamps
    end

    add_index :currencies, :key,  unique: true
  end
end
