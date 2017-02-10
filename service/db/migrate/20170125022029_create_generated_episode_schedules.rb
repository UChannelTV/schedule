class CreateGeneratedEpisodeSchedules < ActiveRecord::Migration
  def change
    create_table :generated_episode_schedules do |t|
      t.integer :channel_id
      t.date :date
      t.integer :program_id
      t.integer :duration
      t.integer :origin
      t.integer :episode
      t.integer :video_id
      t.integer :hour
      t.integer :minute
      t.integer :second
      t.string :remark

      t.timestamps null: false
    end

    add_index :generated_episode_schedules, [:channel_id, :date, :hour, :minute, :second], :unique => true, :name => "main_index"
    add_index :generated_episode_schedules, [:channel_id, :program_id]
    add_index :generated_episode_schedules, :video_id
    execute "ALTER TABLE generated_episode_schedules change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE generated_episode_schedules change `updated_at` `updated_at` timestamp;"
  end
end
