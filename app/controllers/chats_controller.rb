class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats
  end

  def new
    @bills = current_user.bills
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages
  end

  def create
    @chat = current_user.chats.create!(bill_id: params[:bill_id].presence)
    redirect_to chat_path(@chat)
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to chats_path, status: :see_other, notice: "Chat was deleted."
  end
end
