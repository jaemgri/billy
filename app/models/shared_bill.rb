class SharedBill < ApplicationRecord
  belongs_to :bill
  belongs_to :user, optional: true # optional so pending email invites can exist

  enum :role, { viewer: "viewer", commenter: "commenter", editor: "editor" },
       default: "viewer"

  before_validation :normalize_email
  validate :user_or_email_present
  validate :not_the_owner

  scope :pending,  -> { where(user_id: nil) }
  scope :accepted, -> { where.not(user_id: nil) }

  private

  def normalize_email
    self.invited_email = invited_email.to_s.downcase.strip.presence
  end

  def user_or_email_present
    return unless user_id.blank? && invited_email.blank?

    errors.add(:base, "Provide a user or an email address")
  end

  def not_the_owner
    return unless user_id.present? && bill && user_id == bill.user_id

    errors.add(:base, "You already own this bill")
  end
end
