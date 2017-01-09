class ProgramEpisode < ActiveRecord::Base
  validates :program_id, :episode_id, :status, presence: true

  def self.external_name
    "Program Episode"
  end

  def self.external_params(params)
    retVal = params.permit(:program_id, :episode, :date, :video_id, :title,
        :eng_title, :description, :tags, :status, :remark)

    retVal[:episode_id] = retVal[:date] if !retVal[:date].nil?
    retVal[:episode_id] = retVal[:episode] if !retVal[:episode].nil?
    retVal
  end
end
