# Preview all emails at http://localhost:3000/rails/mailers/shared_bill_mailer
class SharedBillMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/shared_bill_mailer/invitation
  def invitation
    SharedBillMailer.invitation
  end
end
