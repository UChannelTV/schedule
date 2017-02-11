class Video < ModelWithStatus
  validates :name, :status, presence: true

  def self.external_name
    "Video"
  end

  def self.external_params(params)
    retVal = params.permit(:name, :path, :format, :size, :duration, :mux_bitrate,
      :variable_mux_rate, :video_codec, :video_bitrate, :frame_rate,
      :video_height, :video_width, :audio_codec, :audio_bitrate,
      :audio_sample_rate, :created_at, :status, :remark, :telvue_id, :is_short_clip)

    retVal[:variable_mux_rate] = false if retVal[:variable_mux_rate].nil?
    puts retVal
    retVal
  end
end
