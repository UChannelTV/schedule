class ChannelScheduleVersion < ActiveRecord::Base
  validates :channel_id, :active_day, presence: true

  def self.external_name
    "Channel Schedule Version"
  end

  def self.external_params(params)
    params.permit(:channel_id, :active_day)
  end
end
