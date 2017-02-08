class CreateChannelScheduleVersions < ActiveRecord::Migration
  def change
    create_table :channel_schedule_versions do |t|
      t.integer :channel_id
      t.date :active_day

      t.timestamps null: false
    end

    execute "ALTER TABLE channel_schedule_versions change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE channel_schedule_versions change `updated_at` `updated_at` timestamp;"
  end
end
