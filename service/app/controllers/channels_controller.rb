class ChannelsController < AdminController
  def initialize
    super(Channel, false)
  end
end
