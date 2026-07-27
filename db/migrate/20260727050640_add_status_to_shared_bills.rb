class AddStatusToSharedBills < ActiveRecord::Migration[8.1]
  def change
    add_column :shared_bills, :status, :string, null: false, default: "pending"
  end
end
