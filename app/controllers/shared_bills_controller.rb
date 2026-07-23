class SharedBillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bill # scoped to current_user.bills => only the owner can manage shares

  def create
    email = params[:shared_bill][:invited_email].to_s.downcase.strip
    user  = User.find_by(email: email)

    @shared_bill = @bill.shared_bills.build(
      user: user,
      invited_email: user ? nil : email,
      role: params[:shared_bill][:role]
    )

    if @shared_bill.save
      SharedBillMailer.invitation(@shared_bill).deliver_later
      redirect_to @bill, notice: "Bill shared with #{email}."
    else
      redirect_to @bill, alert: @shared_bill.errors.full_messages.to_sentence
    end
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
end
