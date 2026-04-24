class HistoryController < ApplicationController
  def show
    @month = parse_month(params[:month])
    range  = month_grid_range(@month)

    @plan_days = current_user
                  .owned_plans
                  .joins(:plan_days)
                  .select("plan_days.id, plan_days.date, plan_days.meal_plan_id")
                  .where(plan_days: { date: range })
                  .map { |r| [r.date, r.id] }

    plan_day_ids = @plan_days.map { |_, id| id }

    counts = Meal.where(plan_day_id: plan_day_ids)
                 .joins(:plan_day)
                 .left_joins(:meal_log)
                 .group("plan_days.date")
                 .pluck(
                   Arel.sql("plan_days.date"),
                   Arel.sql("COUNT(meals.id)"),
                   Arel.sql("SUM(CASE WHEN meal_logs.status IN (1, 3) THEN 1 ELSE 0 END)")
                 )

    @compliance_by_date = counts.to_h { |date, total, filled|
      ratio = total.to_i.zero? ? nil : filled.to_f / total.to_i
      [date, { total: total.to_i, filled: filled.to_i, ratio: ratio }]
    }

    @notes_by_date = current_user.daily_notes
                                 .where(plan_day_id: plan_day_ids)
                                 .joins(:plan_day)
                                 .select("daily_notes.*, plan_days.date AS plan_date")
                                 .index_by(&:plan_date)
  end

  private

  def parse_month(str)
    return Date.current.beginning_of_month if str.blank?
    Date.strptime(str, "%Y-%m").beginning_of_month
  rescue ArgumentError, TypeError
    Date.current.beginning_of_month
  end

  def month_grid_range(month)
    first_of_month = month.beginning_of_month
    last_of_month  = month.end_of_month
    first_of_grid  = first_of_month.beginning_of_week(:monday)
    last_of_grid   = last_of_month.end_of_week(:monday)
    (first_of_grid..last_of_grid)
  end
end
