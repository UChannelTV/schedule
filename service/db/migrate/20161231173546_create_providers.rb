class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :code
      t.string :name
      t.string :full_name
      t.string :eng_name
      t.string :source
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :providers, :code, :unique => true
    add_index :providers, :name, :unique => true
    execute "ALTER TABLE providers change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE providers change `updated_at` `updated_at` timestamp;"
  end
end
