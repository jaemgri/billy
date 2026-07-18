class Bill < ApplicationRecord
  has_many :shared_bills, dependent: :destroy
  has_many :users, through: :shared_bills

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
