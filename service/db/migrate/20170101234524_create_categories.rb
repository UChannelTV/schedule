class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :eng_name
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :categories, :name, :unique => true
    execute "ALTER TABLE categories change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE categories change `updated_at` `updated_at` timestamp;"
  end
end
