class AddUserToBills < ActiveRecord::Migration[8.1]
  def change
    add_reference :bills, :user, null: false, foreign_key: true
  end
end
