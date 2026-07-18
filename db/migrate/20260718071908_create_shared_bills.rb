class CreateSharedBills < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_bills do |t|
      t.references :bill, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
