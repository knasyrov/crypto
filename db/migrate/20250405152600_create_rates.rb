class CreateRates < ActiveRecord::Migration[7.2]
  def change
    create_table :rates do |t|
      t.references :currency, null: false, foreign_key: true
      t.float :value

      t.timestamps
    end
  end
end
