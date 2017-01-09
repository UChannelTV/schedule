class Provider < ModelWithStatus
  validates :code, :name, :full_name, :status, presence: true

  def self.external_name
    "Provider"
  end

  def self.external_params(params)
    params.permit(:code, :name, :full_name, :eng_name, :source, :status, :remark)
  end
end
