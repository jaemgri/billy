class BillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = current_user.bills
  end

  def show
    @bill = Bill.find(params[:id])
  end

  def new
    @bill = Bill.new
  end

  def create
    @bill = current_user.bills.build(bill_params)
    if @bill.save
      redirect_to bill_path(@bill), notice: "Bill was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def bill_params
    params.require(:bill).permit(:title, :description, :amount, :due_date, :received_date, :category)
  end
end
