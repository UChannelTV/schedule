class ScheduleProgramEpisode < ActiveRecord::Base
  validates :channel_id, :date, :program_id, :hour, :minute, :second, presence: true
  validates_inclusion_of :hour, :in => 0..23
  validates_inclusion_of :minute, :in => 0..59
  validates_inclusion_of :second, :in => 0..59

  def self.external_name
    "Schedule Program Esisode"
  end

  def self.external_params(params)
    params.permit(:channel_id, :date, :program_id, :video_id, :expected_duration, :episode, :hour, :minute,
        :second, :remark)
  end

  def self.nextEpisodes(date, program_id, num_episodes)
    episodes = FinalSchedule.where("program_id = #{program_id} and date < '#{date}'").
        order(episode: :desc).limit(1)
    prv_episode = (episodes.size == 0) ? 0 : episodes[0]["episode"]

    ProgramEpisode.select("internal_episode, video_id, duration").
        joins("JOIN videos on videos.id = program_episodes.video_id").
        where("program_id = #{program_id} and internal_episode >= #{prv_episode}").
        order(internal_episode: :asc).limit(num_episodes)
  end
end
