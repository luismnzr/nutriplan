class PlanDay < ApplicationRecord
  belongs_to :meal_plan, inverse_of: :plan_days

  has_many :meals, -> { order(:position, :time) }, dependent: :destroy, inverse_of: :plan_day
  has_many :meal_items, through: :meals
  has_many :daily_notes, dependent: :destroy

  validates :date, presence: true,
                   uniqueness: { scope: :meal_plan_id }
end
