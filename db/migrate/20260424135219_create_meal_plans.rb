class CreateMealPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :meal_plans do |t|
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :notes
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :meal_plans, :start_date
  end
end
