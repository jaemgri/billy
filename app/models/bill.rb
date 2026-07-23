class Bill < ApplicationRecord
  belongs_to :user
  has_many :shared_bills, dependent: :destroy
  has_many :users, through: :shared_bills
  has_many :chats, dependent: :destroy

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
end
