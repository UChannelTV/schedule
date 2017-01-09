class CreateProgramEpisodes < ActiveRecord::Migration
  def change
    create_table :program_episodes do |t|
      t.integer :program_id
      t.string :episode_id
      t.integer :episode
      t.date :date
      t.integer :video_id
      t.boolean :is_short_clip
      t.boolean :is_special
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :program_episodes, [:program_id, :episode_id], :unique => true
    add_index :program_episodes, :video_id, :unique => true
    add_index :program_episodes, :is_short_clip
    execute "ALTER TABLE providers change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE providers change `updated_at` `updated_at` timestamp;"
  end
end
