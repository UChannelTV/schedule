class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.string :timezone

      t.timestamps null: false
    end
   
    execute "ALTER TABLE channels change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE channels change `updated_at` `updated_at` timestamp;"
  end
end
