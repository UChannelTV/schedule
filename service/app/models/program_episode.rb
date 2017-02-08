class ProgramEpisode < ModelWithStatus
  validates :program_id, :video_id, :internal_episode, :status, presence: true

  def self.external_name
    "Program Episode"
  end

  def self.external_params(params)
    retVal = params.permit(:program_id, :internal_episode, :episode, :video_id, :is_special, 
        :status, :remark)

    retVal[:is_special] = false if retVal[:is_special].nil?
    retVal
  end
end
