class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name
      t.integer :converter
      t.string :code
      t.float :buy_price
      t.float :sell_price
      t.references :exchange, index: true
    end
  end
end
