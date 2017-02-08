class ShortClipPromotion < ModelWithStatus
  validates :channel_id, :start_day, :end_day, :start_hour, :num_hours, :program_id, :episode, :num_plays, :status, presence: true
  validates_inclusion_of :start_hour, :in => 0..23
  validates_inclusion_of :num_hours, :in => 1..24
  validate :start_day_end_day_order

  def self.external_name
    "Short Clip Priority"
  end

  def self.external_params(params)
    params.permit(:channel_id, :start_day, :end_day, :start_hour, :num_hours, :program_id, :episode, :num_plays, :status, :remark)
  end

  private

  def start_day_end_day_order
    errors.add(:start_day, "(#{start_day}) cannot be before end day (#{end_day})") unless
        start_day <= end_day
  end
end
