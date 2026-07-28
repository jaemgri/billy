class SearchBillsTool < RubyLLM::Tool
  description "Searches the current user's bills by name or category."
  param :query, desc: "Keyword to search for in bill name or category"

  def initialize(user:)
    @user = user
  end

  def execute(query:)
    bills = @user.bills.where("name ILIKE :q OR category ILIKE :q", q: "%#{query}%")
    return "No bills found matching '#{query}'" if bills.empty?

    bills.map do |b|
      { id: b.id, name: b.name, amount: b.amount, category: b.category, due_date: b.due_date, paid: b.paid }
    end
  end
end
