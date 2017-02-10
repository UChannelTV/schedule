class ScheduleProgram <  ActiveRecord::Base
  validates :channel_id, :version, :program_id, :week_option, :day, :hour, :minute, :second, presence: true
  validates_inclusion_of :day, :in => 0..6
  validates_inclusion_of :hour, :in => 0..23
  validates_inclusion_of :minute, :in => 0..59
  validates_inclusion_of :second, :in => 0..59

  def self.external_name
    "Schedule Program"
  end

  def self.external_params(params)
    params.permit(:channel_id, :version, :program_id, :week_option, :episode_option, :day, :hour, :minute, :second, :remark)
  end
  
  def self._find(channel_id, version, day)
    return where(channel_id: channel_id, version: version).order(hour: :asc, minute: :asc, second: :asc) if day.nil?
    return where(channel_id: channel_id, version: version, day: day).order(hour: :asc, minute: :asc,
        second: :asc)
  end
end
