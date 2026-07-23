class AddPaidToBills < ActiveRecord::Migration[8.1]
  def change
    add_column :bills, :paid, :boolean, default: false
  end
end
