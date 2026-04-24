class MealLogsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_meal
  before_action :ensure_owns_meal

  # POST /meals/:meal_id/meal_log
  def create
    log = @meal.meal_log || @meal.build_meal_log
    log.assign_attributes(log_params)
    log.logged_at = Time.current
    log.save!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@meal, :today),
          partial: "today/meal",
          locals: { meal: @meal.reload }
        )
      end
      format.html { redirect_to today_path }
    end
  end

  private

  def set_meal
    @meal = Meal.includes(:meal_items, :plan_day).find(params[:meal_id])
  end

  def ensure_owns_meal
    head :forbidden unless @meal.plan_day.meal_plan.owner_id == current_user.id
  end

  def log_params
    params.require(:meal_log).permit(:status, :actual_description)
  end
end
