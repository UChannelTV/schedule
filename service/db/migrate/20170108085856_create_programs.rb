class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name
      t.string :code
      t.string :eng_name
      t.integer :category_id
      t.integer :provider_id
      t.integer :total_episodes
      t.string :language
      t.boolean :is_in_house, default: false
      t.boolean :is_live, default: false
      t.boolean :is_children, default: false
      t.integer :expected_duration
      t.string :status
      t.string :remark

      t.timestamps null: false
    end

    add_index :programs, :name, :unique => true
    add_index :programs, :code, :unique => true
    add_index :programs, :provider_id
    add_index :programs, :category_id
    add_index :programs, :status
    execute "ALTER TABLE programs change `created_at` `created_at` datetime not null default CURRENT_TIMESTAMP;"
    execute "ALTER TABLE programs change `updated_at` `updated_at` timestamp;"
  end
end
