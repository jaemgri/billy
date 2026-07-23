class BillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = current_user.bills
    @due_this_month = current_user.bills.where(due_date: Date.today.beginning_of_month..Date.today.end_of_month)
  end

  def show
    @bill = accessible_bills.find(params[:id])
  end

  def new
    @bill = Bill.new
  end

  def destroy
    @bill = current_user.bills.find(params[:id]) # owner-only delete
    @bill.destroy
    redirect_to bills_path, status: :see_other, notice: "Bill was deleted."
  end

  def create
    @bill = current_user.bills.build(bill_params)
    if @bill.save!
      @shared_bill = current_user.shared_bills.build(bill_id: @bill.id)
      @shared_bill.save
      redirect_to bill_path(@bill), notice: "Bill was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @bill = editable_bills.find(params[:id])
  end

  def update
    @bill = editable_bills.find(params[:id])
    if @bill.update(bill_params)
      redirect_to bill_path(@bill), notice: "Bill was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def bill_params
    params.require(:bill).permit(:name, :amount, :description, :due_date, :received_date, :category)
  end

  # Owner + anyone the bill is shared with (any role) can view
  def accessible_bills
    Bill.where(user: current_user)
        .or(Bill.where(id: current_user.shared_with_bills.select(:id)))
  end

  # Owner + editors can edit/update
  def editable_bills
    editor_bill_ids = current_user.shared_bills.where(role: :editor).select(:bill_id)
    Bill.where(user: current_user).or(Bill.where(id: editor_bill_ids))
  end
end
