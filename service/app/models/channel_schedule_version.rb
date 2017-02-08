class ChannelScheduleVersion < ActiveRecord::Base
  validates :channel_id, :active_day, presence: true

  def self.external_name
    "Channel Schedule Version"
  end

  def self.external_params(params)
    params.permit(:channel_id, :active_day)
  end

  def self.get_version(channel_id, date)
    versions = ChannelScheduleVersion.
        where("channel_id = #{channel_id} and active_day <= '#{date}'").
        limit(1)
    return nil if versions.size == 0
    versions[0]["id"]
  end
end
