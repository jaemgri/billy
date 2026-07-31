class BillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = accessible_bills

    raw = params[:start_date].to_s
    @selected_month = begin
      if raw.match?(/\A\d{4}-\d{2}\z/)      # from the month-picker input (Step 3)
        Date.parse("#{raw}-01")
      elsif raw.present?
        Date.parse(raw)                     # from simple_calendar's own Next/Previous links
      else
        Date.today
      end
    rescue ArgumentError
      Date.today
    end

    month_range = @selected_month.beginning_of_month..@selected_month.end_of_month
    @paid_filter = params[:paid_filter].presence_in(%w[unpaid paid all]) || "unpaid"

    bills_in_range = accessible_bills.where(due_date: month_range)
    @due_this_month = case @paid_filter
                      when "unpaid" then bills_in_range.where(paid: false)
                      when "paid"   then bills_in_range.where(paid: true)
                      else               bills_in_range
                      end
    @category_breakdown = @due_this_month
                          .group_by { |bill| bill.category.presence || "Uncategorized" }
                          .transform_values { |bills| bills.sum { |b| b.amount_for(current_user) } }
  end

  def show
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
    @bills = accessible_bills.where(due_date: params[:date])
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

  def category
    @category = params[:category]
    @bills =  if @category == "Uncategorized"
                accessible_bills.where(category: [nil, ""])
              else
                accessible_bills.where(category: @category)
              end
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
    allowed_categories = Bill.categories.values.join(", ")

    "Extract bill information from this image. Return ONLY valid JSON with these keys: " \
      "name (string, the bill or company name), description (string, brief description of what the bill is for), " \
      "amount (number without currency symbol), category (string, must be exactly one of: #{allowed_categories}), " \
      "due_date (string in YYYY-MM-DD format). Use null for any field that cannot be found, " \
      "or for category if none of the listed options apply."
  end

  def ai_parse_bill(image_path)
    chat = RubyLLM.chat(model: "gemini-flash-latest")
    response = chat.ask(ai_parse_prompt, with: { image: image_path })
    Rails.logger.info "RubyLLM response: #{response.content}"
    response.content&.match(/\{.*\}/m)
  end
end
