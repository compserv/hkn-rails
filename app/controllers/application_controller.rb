class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_current_user
  layout 'application'
  
  private
  
  def get_current_user
    if UserSession.find
      @current_user = UserSession.find.person
    end
  end
end
