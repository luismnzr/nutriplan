class CreateDailyNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :daily_notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan_day, null: false, foreign_key: true
      t.integer :overall_score
      t.integer :energy_level
      t.integer :hunger_level
      t.string :mood
      t.text :free_text

      t.timestamps
    end

    add_index :daily_notes, [:user_id, :plan_day_id], unique: true
  end
end
