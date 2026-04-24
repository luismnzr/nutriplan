class Meal < ApplicationRecord
  MEAL_TYPES = { breakfast: 0, lunch: 1, dinner: 2, snack: 3 }.freeze

  belongs_to :plan_day, inverse_of: :meals

  has_many :meal_items, -> { order(:position) }, dependent: :destroy, inverse_of: :meal
  has_one  :meal_log, dependent: :destroy

  enum :meal_type, MEAL_TYPES, validate: true

  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :time) }
end
