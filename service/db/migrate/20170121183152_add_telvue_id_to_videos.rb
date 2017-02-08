class AddTelvueIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :telvue_id, :int
    add_index :videos, :telvue_id
  end
end
