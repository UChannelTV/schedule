class CreateShortClipPriorities < ActiveRecord::Migration
  def change
    create_table :short_clip_priorities do |t|
      t.integer :channel_id
      t.integer :version
      t.integer :start_hour
      t.integer :num_hours
      t.integer :category_id
      t.integer :priority
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :short_clip_priorities, [:channel_id, :version]
    execute "ALTER TABLE short_clip_priorities change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE short_clip_priorities change `updated_at` `updated_at` timestamp;"
  end
end
