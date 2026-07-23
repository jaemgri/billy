class AddSharingFieldsToSharedBills < ActiveRecord::Migration[8.1]
  def change
    # Allow pending invites to people who don't have an account yet
    change_column_null :shared_bills, :user_id, true

    add_column :shared_bills, :invited_email, :string
    add_column :shared_bills, :role, :string

    # Prevent duplicate shares
    add_index :shared_bills, [:bill_id, :user_id],
              unique: true, where: "user_id IS NOT NULL"
    add_index :shared_bills, [:bill_id, :invited_email],
              unique: true, where: "invited_email IS NOT NULL"
  end
end
