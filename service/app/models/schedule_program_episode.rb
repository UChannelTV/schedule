class ScheduleProgramEpisode < ActiveRecord::Base
  validates :channel_id, :date, :program_id, :episode_id, :hour, :minute, :second, :status, presence: true
  validates_inclusion_of :hour, :in => 0..23
  validates_inclusion_of :minute, :in => 0..59
  validates_inclusion_of :second, :in => 0..59

  def self.external_name
    "Schedule Program Esisode"
  end

  def self.external_params(params)
    params.permit(:channel_id, :date, :program_id, :episode_id, :hour, :minute, :second, :status, :remark)
  end
end
