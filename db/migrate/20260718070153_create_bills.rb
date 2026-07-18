class CreateBills < ActiveRecord::Migration[8.1]
  def change
    create_table :bills do |t|
      t.string :name
      t.date :due_date
      t.text :description
      t.decimal :amount
      t.date :received_date
      t.string :category

      t.timestamps
    end
  end
end
