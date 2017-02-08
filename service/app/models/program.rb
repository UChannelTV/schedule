class Program < ModelWithStatus
  validates :code, :name, :category_id, :provider_id, :expected_duration, :status, presence: true

  def self.external_name
    "Program"
  end

  def self.external_params(params)
    retVal = params.permit(:code, :name, :eng_name, :total_episodes, :category_id,
        :provider_id, :expected_duration, :language, :is_in_house, :is_live,
        :is_children, :status, :remark)
    
    retVal[:is_in_house] = false if retVal[:is_in_house].nil?
    retVal[:is_live] = false if retVal[:is_live].nil?
    retVal[:is_children] = false if retVal[:is_children].nil?
    retVal
  end

  def self._find(provider_id, category_id, status, limit)
    conditions = []
    conditions << "provider_id = #{provider_id}" if provider_id.to_i > 0
    conditions << "category_id = #{category_id}" if category_id.to_i > 0
    conditions << "status = '#{status}'" if status != "all"
    
    return order(name: :asc).limit(limit) if conditions.size == 0 
    return where(conditions.join(" AND ")).order(name: :asc).limit(limit)
  end
end
