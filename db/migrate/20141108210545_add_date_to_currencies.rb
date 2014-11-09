class AddDateToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :date, :date
  end
end