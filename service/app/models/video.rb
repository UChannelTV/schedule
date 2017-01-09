class Video < ActiveRecord::Base
  validates :path, :format, :size, :duration, :mux_bitrate, :variable_mux_rate, 
      :video_codec, :video_bitrate, :frame_rate, :video_height, :video_width,
      :audio_codec, :audio_bitrate, :audio_sample_rate, :status, presence: true

  def self.external_name
    "Video"
  end

  def self.external_params(params)
    params.permit(:path, :format, :size, :duration, :mux_bit_rate, :variable_mux_rate, 
      :video_codec, :video_bitrate, :frame_rate, :video_height, :video_width,
      :audio_codec, :audio_bitrate, :audio_sample_rate, :status, :remark)
  end
end
