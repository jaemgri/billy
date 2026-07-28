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
  enum :category, { food: "Food", utilities: "Utilities", rent: "Rent", subscription: "Subscription", Entertainment: "Entertainment", other: "Other" }, validate: { allow_nil: true }

  def owner_remaining_amount
    amount.to_f - shared_bills.sum(:split_amount).to_f
  end

  scope :paid,    -> { where(paid: true) }
  scope :unpaid,  -> { where(paid: false) }
  scope :overdue, -> { unpaid.where(due_date: ...Date.today) }

  def mark_as_paid!
    update!(paid: true, paid_at: Time.current)
  end

  def mark_as_unpaid!
    update!(paid: false, paid_at: nil)
  end

  def overdue?
    !paid? && due_date.present? && due_date < Date.today
  end

  private

  def round_amount
    self.amount = amount.to_f.round if amount.present?
  end
end
