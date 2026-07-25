class SharedBillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bill, only: %i[create update destroy] # scoped to current_user.bills => only the owner can manage shares
  before_action :set_owned_shared_bill, only: %i[update destroy]

  def create
    email = params[:shared_bill][:invited_email].to_s.downcase.strip
    user  = User.find_by(email: email)

    @shared_bill = @bill.shared_bills.build(
      user: user,
      invited_email: user ? nil : email,
      role: params[:shared_bill][:role]
    )

    if @shared_bill.save
      SharedBillMailer.invitation(@shared_bill).deliver_now
      redirect_to @bill, notice: "Bill shared with #{email}."
    else
      redirect_to @bill, alert: @shared_bill.errors.full_messages.to_sentence
    end
  end

  def update
    if @shared_bill.update(split_params)
      redirect_to @bill, notice: "Split updated."
    else
      redirect_to @bill, alert: @shared_bill.errors.full_messages.to_sentence
    end
  end

  def mark_paid
    @shared_bill = current_user.shared_bills.find(params[:id])
    @shared_bill.update(paid: true)
    redirect_to bill_path(@shared_bill.bill), notice: "Marked as paid."
  end

  def destroy
    @shared_bill = @bill.shared_bills.find(params[:id])
    @shared_bill.destroy
    redirect_to @bill, status: :see_other, notice: "Access removed."
  end

  private

  def set_bill
    @bill = current_user.bills.find(params[:bill_id])
  end

  def set_owned_shared_bill
    @shared_bill = @bill.shared_bills.find(params[:id])
  end

  def split_params
    params.require(:shared_bill).permit(:split_amount)
  end
end
