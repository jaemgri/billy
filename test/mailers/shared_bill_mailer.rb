class SharedBillMailer < ApplicationMailer
  def invitation(shared_bill)
    @shared_bill = shared_bill
    @bill        = shared_bill.bill
    recipient    = shared_bill.user&.email || shared_bill.invited_email
    mail(to: recipient, subject: "A bill was shared with you on Billy")
  end
end
