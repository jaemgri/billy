class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bills, dependent: :destroy
  has_many :shared_bills, dependent: :destroy
  has_many :shared_with_bills, through: :shared_bills, source: :bill
  has_many :chats, dependent: :destroy

  before_validation :generate_username, on: :create

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" },
                       length: { in: 3..20 }

  after_create :claim_pending_shared_bills

  private

  def claim_pending_shared_bills
    SharedBill.pending.where(invited_email: email).update_all(user_id: id)
  end

  def generate_username
    return if username.present? # only kicks in if the user left it blank

    base = email.to_s.split("@").first.to_s.downcase.gsub(/[^a-z0-9]/, "")
    base = "user" if base.blank?

    candidate = base
    suffix = 1
    while User.exists?(username: candidate)
      candidate = "#{base}#{suffix}"
      suffix += 1
    end

    self.username = candidate
  end
end
