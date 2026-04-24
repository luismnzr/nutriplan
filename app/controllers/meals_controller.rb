class MealsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_plan,    only: :create
  before_action :set_meal,    only: :destroy
  before_action :ensure_owns_meal, only: :destroy

  # POST /plans/:plan_id/meals
  def create
    day = @plan.plan_days.find(params.dig(:meal, :plan_day_id))
    next_pos = (day.meals.maximum(:position) || -1) + 1
    @meal = day.meals.create!(
      meal_type: params.dig(:meal, :meal_type) || "snack",
      time: params.dig(:meal, :time),
      position: next_pos
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          dom_id(day, :snacks),
          partial: "meals/meal",
          locals: { meal: @meal }
        )
      end
      format.html { redirect_to edit_plan_path(@plan) }
    end
  end

  # DELETE /meals/:id
  def destroy
    meal = @meal
    plan = meal.plan_day.meal_plan
    meal.destroy!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(meal)) }
      format.html { redirect_to edit_plan_path(plan) }
    end
  end

  private

  def set_plan
    @plan = current_user.owned_plans.find(params[:plan_id])
  end

  def set_meal
    @meal = Meal.find(params[:id])
  end

  def ensure_owns_meal
    plan = @meal.plan_day.meal_plan
    head :forbidden unless plan.owner_id == current_user.id
  end
end
