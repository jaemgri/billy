class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :bill
  has_many :messages, dependent: :destroy
end
