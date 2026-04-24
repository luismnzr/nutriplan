class CreateShoppingListChecks < ActiveRecord::Migration[7.2]
  def change
    create_table :shopping_list_checks do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.string :item_key, null: false

      t.timestamps
    end

    add_index :shopping_list_checks, [:meal_plan_id, :item_key], unique: true
  end
end
