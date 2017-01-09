class CreateSchedulePrograms < ActiveRecord::Migration
  def change
    create_table :schedule_programs do |t|
      t.integer :channel_id
      t.integer :version
      t.string :program_id
      t.integer :week_option
      t.integer :day
      t.integer :hour
      t.integer :minute
      t.integer :second
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :schedule_programs, [:channel_id, :version]
    execute "ALTER TABLE schedule_programs change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE schedule_programs change `updated_at` `updated_at` timestamp;"
  end
end
