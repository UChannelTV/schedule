class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :path
      t.string :format
      t.integer :size
      t.integer :duration
      t.float :mux_bitrate
      t.boolean :variable_mux_rate
      t.string :video_codec
      t.float :video_bitrate
      t.float :frame_rate
      t.integer :video_height
      t.integer :video_width
      t.string :audio_codec
      t.float :audio_bitrate
      t.integer :audio_sample_rate
      t.string :status
      t.string :remark
      t.timestamps null: false
    end

    add_index :videos, :path, :unique => true
    execute "ALTER TABLE videos change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE videos change `updated_at` `updated_at` timestamp;"
  end
end
