class MessagesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = <<~PROMPT
    You are Billy, a friendly personal finance assistant that helps users understand and manage their bills.

    The user is a person tracking their household bills in the Billy app.

    You have access to tools that let you actually make changes:
    - Mark a bill as paid or unpaid
    - Update a bill's amount, category, name, or due date
    - Share a bill with someone by email, optionally splitting a specific amount
    - Search the user's bills by name or category

    When sharing a bill, mention whether the recipient already has a Billy account or will receive an invitation email to sign up, based on the tool's result.

    Only use these tools when the user clearly asks for an action. Confirm what you did in your reply using the tool's result — never claim to have done something a tool didn't actually confirm.

    Answer concisely, in plain text or simple Markdown.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = @chat.messages.create!(role: "user", content: params[:content])

    ruby_llm_chat = RubyLLM.chat(model: "gemini-flash-latest")
    build_conversation_history(ruby_llm_chat)

    ruby_llm_chat.with_tool(MarkBillPaidTool.new(user: current_user))
    ruby_llm_chat.with_tool(UpdateBillTool.new(user: current_user))
    ruby_llm_chat.with_tool(ShareBillTool.new(user: current_user))
    ruby_llm_chat.with_tool(SearchBillsTool.new(user: current_user))

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

    "Here is the bill this conversation is about: id #{@chat.bill.id}, #{@chat.bill.name}, amount: ¥#{@chat.bill.amount}, category: #{@chat.bill.category}, due: #{@chat.bill.due_date}, paid: #{@chat.bill.paid}."
  end
end
