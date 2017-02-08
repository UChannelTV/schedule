class ShortClipPriority < ModelWithStatus
  validates :channel_id, :version, :start_hour, :num_hours, :category_id, :priority, :status, presence: true
  validates_inclusion_of :start_hour, :in => 0..23
  validates_inclusion_of :num_hours, :in => 1..24

  def self.external_name
    "Short Clip Priority"
  end

  def self.external_params(params)
    params.permit(:channel_id, :version, :start_hour, :num_hours, :category_id, :priority, :status, :remark)
  end
end
