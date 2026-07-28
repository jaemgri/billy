class Bill < ApplicationRecord
  belongs_to :user
  has_many :shared_bills, dependent: :destroy
  has_many :users, through: :shared_bills
  has_many :chats, dependent: :destroy

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  before_validation :round_amount
  validates :amount, numericality: { only_integer: true, allow_nil: true }

  def owner_remaining_amount
    amount.to_f - shared_bills.sum(:split_amount).to_f
  end

  private

  def round_amount
    self.amount = amount.to_f.round if amount.present?
  end
end
