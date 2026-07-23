class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bills, dependent: :destroy
  has_many :shared_bills, dependent: :destroy
  has_many :shared_with_bills, through: :shared_bills, source: :bill
  has_many :chats, dependent: :destroy
end
