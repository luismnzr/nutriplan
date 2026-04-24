class MealPlan < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :assignee, class_name: "User"

  has_many :plan_days, -> { order(:date) }, dependent: :destroy, inverse_of: :meal_plan
  has_many :meals, through: :plan_days
  has_many :meal_items, through: :meals
  has_many :shopping_list_checks, dependent: :destroy

  validates :name, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_on_or_after_start_date

  scope :active_on, ->(date) { where("start_date <= ? AND end_date >= ?", date, date) }

  def personal?
    owner == assignee
  end

  # Returns an array of hashes:
  # [{ key:, description:, quantity:, checked: }, ...]
  # sorted alphabetically by description.
  def shopping_list
    grouped = {}

    meal_items.includes(:meal).find_each do |item|
      key = normalize_key(item.description)
      next if key.empty?
      grouped[key] ||= { description: item.description.to_s.strip, quantities: [] }
      grouped[key][:quantities] << item.quantity
    end

    checked_keys = shopping_list_checks.pluck(:item_key).to_set

    grouped.map { |key, data|
      {
        key:         key,
        description: data[:description],
        quantity:    QuantityParser.aggregate(data[:quantities]),
        checked:     checked_keys.include?(key)
      }
    }.sort_by { |row| row[:description].downcase }
  end

  def normalize_key(description)
    description.to_s.downcase.strip.squeeze(" ")
  end

  private

  def end_date_on_or_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "no puede ser anterior a start_date") if end_date < start_date
  end
end
