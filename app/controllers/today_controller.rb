class TodayController < ApplicationController
  def show
    today = Date.current
    @plan = current_user.owned_plans
                        .active_on(today)
                        .order(created_at: :desc)
                        .first
    return unless @plan

    @plan_day = @plan.plan_days.find_by(date: today)
    @meals = @plan_day&.meals&.ordered&.includes(:meal_items, :meal_log).to_a || []
    @daily_note = @plan_day && current_user.daily_notes.find_or_initialize_by(plan_day_id: @plan_day.id)
  end
end
