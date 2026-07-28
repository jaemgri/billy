class UpdateBillTool < RubyLLM::Tool
  description "Updates a bill's amount, category, name, or due date for the current user."
  param :bill_id, desc: "The ID of the bill to update", type: :integer
  param :amount, desc: "New amount, if changing", type: :number, required: false
  param :category, desc: "New category, if changing", required: false
  param :name, desc: "New name, if changing", required: false
  param :due_date, desc: "New due date (YYYY-MM-DD), if changing", required: false

  def initialize(user:)
    @user = user
  end

  def execute(bill_id:, amount: nil, category: nil, name: nil, due_date: nil)
    bill = @user.bills.find(bill_id)
    updates = {}
    updates[:amount] = amount if amount
    updates[:category] = category if category
    updates[:name] = name if name
    updates[:due_date] = due_date if due_date
    bill.update!(updates)
    { status: "success", bill: bill.name, amount: bill.amount, category: bill.category, due_date: bill.due_date }
  rescue ActiveRecord::RecordNotFound
    { error: "Bill not found" }
  rescue ActiveRecord::RecordInvalid => e
    { error: e.message }
  end
end
