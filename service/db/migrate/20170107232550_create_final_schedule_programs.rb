class CreateFinalSchedulePrograms < ActiveRecord::Migration
  def change
    create_table :final_schedule_programs do |t|
      t.integer :channel_id
      t.date :date
      t.integer :program_id
      t.string :episode_id
      t.integer :hour
      t.integer :minute
      t.integer :second
      t.string :status
      t.string :remark

      t.timestamps null: false
    end
    
    add_index :final_schedule_programs, [:channel_id, :date]
    execute "ALTER TABLE final_schedule_programs change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE final_schedule_programs change `updated_at` `updated_at` timestamp;"
  end
end
