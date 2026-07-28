class AddPaidToBills < ActiveRecord::Migration[8.1]
  def change
    add_column :bills, :paid, :boolean, default: false, null: false unless column_exists?(:bills, :paid)
    add_column :bills, :paid_at, :datetime unless column_exists?(:bills, :paid_at)
  end
end
