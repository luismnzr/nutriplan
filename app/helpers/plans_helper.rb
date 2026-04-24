module PlansHelper
  MEAL_ROWS = %w[breakfast lunch dinner snack].freeze

  def meal_type_label(type)
    t("meal_types.#{type}")
  end

  def day_column_header(day)
    content_tag(:div, class: "flex flex-col items-center py-2") do
      concat content_tag(:span, I18n.l(day.date, format: "%a").capitalize, class: "text-[10px] uppercase tracking-wider text-ink-400")
      concat content_tag(:span, I18n.l(day.date, format: "%-d %b"), class: "text-sm font-medium text-ink-200")
    end
  end

  def meals_for(day, type)
    day.meals.select { |m| m.meal_type == type }.sort_by(&:position)
  end
end
