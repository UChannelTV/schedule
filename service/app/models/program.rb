class Program < ModelWithStatus
  validates :code, :name, :category_id, :provider_id, :status, presence: true

  def self.external_name
    "Program"
  end

  def self.external_params(params)
    retVal = params.permit(:code, :name, :eng_name, :category_id, :provider_id,
        :total_episodes, :expected_duration, :language, :is_in_house, :is_live,
        :is_children, :status, :remark)
    
    retVal[:is_in_house] = false if retVal[:is_in_house].nil?
    retVal[:is_live] = false if retVal[:is_live].nil?
    retVal[:is_children] = false if retVal[:is_children].nil?
    retVal
  end
end
