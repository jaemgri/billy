class AllowNullBillIdOnChats < ActiveRecord::Migration[8.1]
  def change
    change_column_null :chats, :bill_id, true
  end
end
