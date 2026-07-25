class SharedBillMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.shared_bill_mailer.invitation.subject
  #
  def invitation(shared_bill)
    @shared_bill = shared_bill
    @bill        = shared_bill.bill
    recipient    = shared_bill.user&.email || shared_bill.invited_email

    mail(
      to: recipient,
      reply_to: @bill.user.email,
      subject: "A bill was shared with you on Billy"
    )
  end
end
