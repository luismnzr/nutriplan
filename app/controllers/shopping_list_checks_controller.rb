class ShoppingListChecksController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_plan

  # POST /plans/:plan_id/shopping_list_checks/toggle
  def toggle
    key = params.require(:item_key).to_s
    check = @plan.shopping_list_checks.find_by(item_key: key)

    if check
      check.destroy!
      checked = false
    else
      @plan.shopping_list_checks.create!(item_key: key)
      checked = true
    end

    row = @plan.shopping_list.find { |r| r[:key] == key }
    row ||= { key: key, description: key.titleize, quantity: "", checked: checked }
    row[:checked] = checked

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "shopping_item_#{Digest::MD5.hexdigest(key)}",
          partial: "shopping_list/item",
          locals: { plan: @plan, row: row }
        )
      end
      format.html { redirect_to shopping_list_plan_path(@plan) }
    end
  end

  private

  def set_plan
    @plan = current_user.owned_plans.find(params[:id])
  end
end
