class CreateProgramEpisodes < ActiveRecord::Migration
  def change
    create_table :program_episodes do |t|
      t.integer :program_id
      t.integer :internal_episode
      t.string :episode
      t.integer :video_id
      t.boolean :is_special
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :program_episodes, [:program_id, :internal_episode], :unique => true
    add_index :program_episodes, :video_id, :unique => true
    add_index :program_episodes, :status
    execute "ALTER TABLE program_episodes change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE program_episodes change `updated_at` `updated_at` timestamp;"
  end
end
