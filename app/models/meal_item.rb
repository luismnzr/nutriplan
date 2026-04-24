class MealItem < ApplicationRecord
  belongs_to :meal, inverse_of: :meal_items

  validates :description, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :normalize_swap_options

  private

  def normalize_swap_options
    self.swap_options = Array(swap_options).map { |s| s.to_s.strip }.reject(&:blank?)
  end
end
