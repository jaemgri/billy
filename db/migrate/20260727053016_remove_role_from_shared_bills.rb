class RemoveRoleFromSharedBills < ActiveRecord::Migration[8.1]
  def change
    remove_column :shared_bills, :role, :string, default: "viewer"
  end
end
