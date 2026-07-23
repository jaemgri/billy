class AddBillToChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :chats, :bill, null: false, foreign_key: true
  end
end
