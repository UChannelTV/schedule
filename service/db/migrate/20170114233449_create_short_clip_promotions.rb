class CreateShortClipPromotions < ActiveRecord::Migration
  def change
    create_table :short_clip_promotions do |t|
      t.integer :channel_id
      t.date :start_day
      t.date :end_day
      t.integer :start_hour
      t.integer :num_hours
      t.integer :program_id
      t.integer :episode
      t.integer :num_plays
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :short_clip_promotions, [:channel_id, :start_day, :end_day], :name => "main_index"
    execute "ALTER TABLE short_clip_promotions change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE short_clip_promotions change `updated_at` `updated_at` timestamp;"
  end
end
