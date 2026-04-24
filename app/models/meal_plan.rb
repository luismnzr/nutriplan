class MealPlan < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :assignee, class_name: "User"

  has_many :plan_days, -> { order(:date) }, dependent: :destroy, inverse_of: :meal_plan
  has_many :meals, through: :plan_days
  has_many :meal_items, through: :meals

  validates :name, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_on_or_after_start_date

  scope :active_on, ->(date) { where("start_date <= ? AND end_date >= ?", date, date) }

  def personal?
    owner == assignee
  end

  private

  def end_date_on_or_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "no puede ser anterior a start_date") if end_date < start_date
  end
end
