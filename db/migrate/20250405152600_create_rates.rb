class CreateRates < ActiveRecord::Migration[7.2]
  def change
    create_table :rates do |t|
      t.references :currency, null: false, foreign_key: true
      t.decimal :value, precision: 16, scale: 8

      t.timestamps
    end
  end
end
