class HomeController < ApplicationController
  def index
    @show_searcharea = true
    if UserSession.find
      @current_user = UserSession.find.person
    end
  end

end
