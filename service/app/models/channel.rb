class Channel < ActiveRecord::Base
  validates :name, :timezone, presence: true

  def self.external_name
    "Channel"
  end

  def self.external_params(params)
    params.permit(:name, :timezone)
  end
end
