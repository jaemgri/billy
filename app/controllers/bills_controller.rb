class BillsController < ApplicationController
  before_action :authenticate_user!

  def index
    start_date = params.fetch(:start_date, Date.today).to_date
    @bills = current_user.bills.where(
      due_date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week
    )
  end

  def show
    @bill = Bill.find(params[:id])
  end

  def new
    @bill = Bill.new
  end

  def destroy
    @bill = current_user.bills.find(params[:id])
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

  private

  def bill_params
    params.require(:bill).permit(:name, :amount, :description, :due_date, :received_date, :category)
  end
end
