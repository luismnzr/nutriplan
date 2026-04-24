class MealLog < ApplicationRecord
  STATUSES = { planned: 0, eaten: 1, skipped: 2, modified: 3 }.freeze

  belongs_to :meal

  enum :status, STATUSES, validate: true

  scope :completed, -> { where(status: [:eaten, :modified]) }

  def fulfilled?
    eaten? || modified?
  end
end
