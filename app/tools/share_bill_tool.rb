class ShareBillTool < RubyLLM::Tool
  description "Shares a bill with another person by email, optionally splitting a specific amount with them."
  param :bill_id, desc: "The ID of the bill to share", type: :integer
  param :email, desc: "Email address of the person to share with"
  param :split_amount, desc: "The amount this person owes, if splitting", type: :number, required: false

  def initialize(user:)
    @user = user
  end

  def execute(bill_id:, email:, split_amount: nil)
    bill = @user.bills.find(bill_id)
    shared_user = User.find_by(email: email.downcase.strip)

    shared_bill = bill.shared_bills.create!(
      user: shared_user,
      invited_email: shared_user ? nil : email.downcase.strip,
      split_amount: split_amount
    )

    SharedBillMailer.invitation(shared_bill).deliver_now

    {
      status: "success",
      bill: bill.name,
      total_amount: bill.amount,
      shared_with: email,
      their_share: shared_bill.split_amount,
      your_remaining_share: bill.owner_remaining_amount,
      has_account: shared_user.present?
    }
  rescue ActiveRecord::RecordNotFound
    { error: "Bill not found" }
  rescue ActiveRecord::RecordInvalid => e
    { error: e.message }
  end
end
