class ModelWithStatus < ActiveRecord::Base
  self.abstract_class = true  
  STATUS_OPTION = ["active", "expired"]
  validates :status, :inclusion => {:in => STATUS_OPTION}
end
