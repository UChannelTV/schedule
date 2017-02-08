class GeneratedEpisodeSchedule < ActiveRecord::Base
  validates :channel_id, :date, :program_id, :duration, :video_id, :hour, :minute, :second, presence: true
  validates_inclusion_of :hour, :in => 0..23
  validates_inclusion_of :minute, :in => 0..59
  validates_inclusion_of :second, :in => 0..59

  def self.external_name
    "Final Schedule"
  end

  def self.external_params(params)
    params.permit(:channel_id, :date, :program_id, :video_id, :telvue_id, :episode, :hour, :minute, :second, :remark)
  end
end
