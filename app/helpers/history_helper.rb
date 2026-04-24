module HistoryHelper
  DAY_ABBR = %w[Lun Mar Mié Jue Vie Sáb Dom].freeze

  def history_grid_range(month)
    first = month.beginning_of_month.beginning_of_week(:monday)
    last  = month.end_of_month.end_of_week(:monday)
    (first..last).to_a
  end

  def score_cell_classes(score, in_month:)
    base = in_month ? "" : "opacity-30"
    color =
      case score
      when nil then "border border-ink-800 bg-ink-950"
      when 1   then "bg-red-500/60 text-red-50"
      when 2   then "bg-red-500/30 text-red-100"
      when 3   then "bg-amber-500/40 text-amber-50"
      when 4   then "bg-accent-500/40 text-accent-50"
      when 5   then "bg-accent-500/80 text-white"
      end
    "#{color} #{base}"
  end

  def compliance_cell_classes(ratio, in_month:)
    base = in_month ? "" : "opacity-30"
    color =
      if ratio.nil?
        "border border-ink-800 bg-ink-950"
      elsif ratio < 0.5
        "bg-red-500/50"
      elsif ratio < 0.8
        "bg-amber-500/40"
      else
        "bg-accent-500/70"
      end
    "#{color} #{base}"
  end

  def format_month(month)
    I18n.l(month, format: "%B %Y").capitalize
  end
end
