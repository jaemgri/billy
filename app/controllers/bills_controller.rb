class BillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = accessible_bills
    @due_this_month = accessible_bills.where(paid: false,
                                             due_date: Date.today.beginning_of_month..Date.today.end_of_month)
  end

  def show
    # @bill = accessible_bills.find(params[:id])
    @bill = viewable_bills.find(params[:id])
    @my_shared_bill = current_user.shared_bills.find_by(bill_id: @bill.id)
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
    if @bill.save # .save! raises on failure instead of returning false, so inside an if, the else/render :new branch never runs.
      redirect_to bill_path(@bill), notice: "Bill was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @bill = accessible_bills.find(params[:id])
  end

  def update
    @bill = accessible_bills.find(params[:id])
    was_paid = @bill.paid?

    if @bill.update(bill_params)
      @bill.mark_as_paid!   if !was_paid && @bill.paid?
      @bill.mark_as_unpaid! if was_paid  && !@bill.paid?
      redirect_to bill_path(@bill), notice: "Bill was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def date
    @target_date = params[:date]
    @bills = current_user.bills.where(due_date: params[:date])
  end

  def extract_from_image
    image = params[:image]
    return render json: { error: "No image provided" }, status: :bad_request unless image

    # Upload to Cloudinary for storage
    Cloudinary::Uploader.upload(image.path, folder: "billy/bill_scans")

    json_match = ai_parse_bill(image.path)

    if json_match
      render json: JSON.parse(json_match[0])
    else
      render json: { error: "Could not extract data from image", raw: text }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "extract_from_image error: #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def bill_params
    params.require(:bill).permit(:name, :amount, :description, :due_date, :received_date, :category, :paid)
  end

  # Owner + anyone invited (any status) — used by `show` so pending invitees can open the link
  def viewable_bills
    Bill.where(user: current_user)
        .or(Bill.where(id: current_user.shared_bills.select(:bill_id)))
  end

  # Owner + accepted shares only — used by `index`/calendar
  def accessible_bills
    Bill.where(user: current_user)
        .or(Bill.where(id: current_user.shared_bills.accepted.select(:bill_id)))
  end

  def ai_parse_prompt
    "Extract bill information from this image. Return ONLY valid JSON with these keys: name (string, the bill or company name), description (string, brief description of what the bill is for), amount (number without currency symbol), category (string, e.g. Utilities, Rent, Subscription), due_date (string in YYYY-MM-DD format). Use null for any field that cannot be found."
  end

  def ai_parse_bill(image_path)
    chat = RubyLLM.chat(model: "gemini-flash-latest")
    response = chat.ask(ai_parse_prompt, with: { image: image_path })
    Rails.logger.info "RubyLLM response: #{response.content}"
    response.content&.match(/\{.*\}/m)
  end
end
