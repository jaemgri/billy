class MarkBillPaidTool < RubyLLM::Tool
  description "Marks a specific bill as paid or unpaid for the current user."
  param :bill_id, desc: "The ID of the bill", type: :integer
  param :paid, desc: "true to mark as paid, false to mark as unpaid", type: :boolean

  def initialize(user:)
    @user = user
  end

  def execute(bill_id:, paid:)
    bill = @user.bills.find(bill_id)
    paid ? bill.mark_as_paid! : bill.mark_as_unpaid!
    { status: "success", bill: bill.name, paid: bill.paid }
  rescue ActiveRecord::RecordNotFound
    { error: "Bill not found" }
  end
end
