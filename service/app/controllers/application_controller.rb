class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token, if: :json_request?

  before_filter :family

  private
    def json_request?
      "application/json".eql?(request.content_type.to_s.downcase)
    end

    def family
      if ["providers", "categories", "programs", "program_episodes", "short_clips", "videos"].include?(params[:controller])
        @family = "program"
      else  
        @family = "schedule"
      end    	
    end
end
