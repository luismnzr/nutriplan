class CreateMeals < ActiveRecord::Migration[7.2]
  def change
    create_table :meals do |t|
      t.references :plan_day, null: false, foreign_key: true
      t.integer :meal_type, null: false
      t.time :time
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :meals, [:plan_day_id, :position]
  end
end
