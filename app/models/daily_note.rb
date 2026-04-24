class DailyNote < ApplicationRecord
  SCORE_RANGE = 1..5

  belongs_to :user
  belongs_to :plan_day

  validates :user_id, uniqueness: { scope: :plan_day_id }
  validates :overall_score, :energy_level, :hunger_level,
            numericality: { only_integer: true, in: SCORE_RANGE },
            allow_nil: true
  validates :mood, length: { maximum: 40 }, allow_nil: true
end
