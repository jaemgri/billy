class AllowNullUserIdOnSharedBills < ActiveRecord::Migration[8.1]
  def change
    change_column_null :shared_bills, :user_id, true
  end
end
