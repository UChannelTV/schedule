class CreateChannelScheduleVersions < ActiveRecord::Migration
  def change
    create_table :channel_schedule_versions do |t|
      t.integer :channel_id
      t.date :active_day

      t.timestamps null: false
    end
  end
end
