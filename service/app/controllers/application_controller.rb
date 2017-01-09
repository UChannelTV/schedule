class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :family

  private
    def family
      if ["providers", "categories", "programs", "program_episodes", "videos"].include?(params[:controller])
        @family = "program"
      else  
        @family = "schedule"
      end    	
    end
end
