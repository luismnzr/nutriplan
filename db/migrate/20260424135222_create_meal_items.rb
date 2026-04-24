class CreateMealItems < ActiveRecord::Migration[7.2]
  def change
    create_table :meal_items do |t|
      t.references :meal, null: false, foreign_key: true
      t.text :description, null: false
      t.string :quantity
      t.text :swap_options, array: true, null: false, default: []
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
