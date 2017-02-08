class AddEpisodeOptionToSchedulePrograms < ActiveRecord::Migration
  def change
    add_column :schedule_programs, :episode_option, :int, :default => 1
  end
end
