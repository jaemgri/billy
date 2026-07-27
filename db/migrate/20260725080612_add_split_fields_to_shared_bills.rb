class AddSplitFieldsToSharedBills < ActiveRecord::Migration[8.1]
  def change
    add_column :shared_bills, :split_amount, :decimal
    add_column :shared_bills, :paid, :boolean
  end
end
