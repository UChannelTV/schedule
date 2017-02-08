class ShortClip < ModelWithStatus
  validates :program_id, :category_id, :duration, :video_id, :status, presence: true

  def self.external_name
    "Short Clip"
  end

  def self.external_params(params)
    retVal = params.permit(:program_id, :episode, :category_id, :duration, :video_id,
        :is_special, :status, :remark)

    retVal[:is_special] = false if retVal[:is_special].nil?
    retVal
  end
end
