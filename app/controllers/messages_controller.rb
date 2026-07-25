class MessagesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = <<~PROMPT
    You are Billy, a friendly personal finance assistant that helps users understand and manage their bills.

    The user is a person tracking their household bills in the Billy app.

    IMPORTANT: You cannot actually modify, update, or mark bills as paid — you can only provide information, explanations, and calculations. If the user asks you to make a change, explain what they should do manually in the app instead of claiming you did it.

    Answer concisely, in plain text or simple Markdown. Keep responses short and practical.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = @chat.messages.create!(role: "user", content: params[:content])

    ruby_llm_chat = RubyLLM.chat(model: "gemini-flash-latest")
    build_conversation_history(ruby_llm_chat)

    response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
    @assistant_message = @chat.messages.create!(role: "assistant", content: response.content)

    redirect_to chat_path(@chat)
  end

  private

  def build_conversation_history(ruby_llm_chat)
    @chat.messages.each do |message|
      ruby_llm_chat.add_message(role: message.role.to_sym, content: message.content)
    end
  end

  def instructions
    [SYSTEM_PROMPT, bill_context].compact.join("\n\n")
  end

  def bill_context
    return nil unless @chat.bill

    "Here is the bill this conversation is about: #{@chat.bill.name}, amount: ¥#{@chat.bill.amount}, category: #{@chat.bill.category}, due: #{@chat.bill.due_date}."
  end
end
