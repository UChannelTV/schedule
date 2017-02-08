class CreateShortClips < ActiveRecord::Migration
  def change
    create_table :short_clips do |t|
      t.integer :program_id
      t.string :episode
      t.integer :category_id
      t.integer :duration
      t.integer :video_id
      t.boolean :is_special
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :short_clips, :program_id
    add_index :short_clips, :video_id, :unique => true
    add_index :short_clips, [:duration, :category_id]
    add_index :short_clips, :status
    execute "ALTER TABLE short_clips change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE short_clips change `updated_at` `updated_at` timestamp;"
  end
end
