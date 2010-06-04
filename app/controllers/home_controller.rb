class HomeController < ApplicationController
  def index
    if UserSession.find
      @current_user = UserSession.find.person
    end
  end

end
