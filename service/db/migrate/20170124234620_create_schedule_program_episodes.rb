class CreateScheduleProgramEpisodes < ActiveRecord::Migration
  def change
    create_table :schedule_program_episodes do |t|
      t.integer :channel_id
      t.date :date
      t.integer :program_id
      t.integer :expected_duration
      t.integer :episode
      t.integer :video_id
      t.integer :hour
      t.integer :minute
      t.integer :second
      t.string :remark

      t.timestamps null: false
    end

    add_index :schedule_program_episodes, [:channel_id, :date, :hour, :minute, :second], :unique => true, :name => "main_index"
    add_index :schedule_program_episodes, [:channel_id, :program_id]
    add_index :schedule_program_episodes, :video_id
    execute "ALTER TABLE schedule_program_episodes change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE schedule_program_episodes change `updated_at` `updated_at` timestamp;"
  end
end
