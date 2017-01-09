class Category < ModelWithStatus 
  validates :name, :status, presence: true

  def self.external_name
    "Category"
  end

  def self.external_params(params)
    params.permit(:name, :eng_name, :status, :remark)
  end

end
