class ShoppingListCheck < ApplicationRecord
  belongs_to :meal_plan

  validates :item_key, presence: true,
                       uniqueness: { scope: :meal_plan_id }
end
