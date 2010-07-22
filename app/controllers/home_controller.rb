class HomeController < ApplicationController
  def index
    @show_searcharea = true
    @tutoring_enabled = true
    @hours = Property.tutoring_start .. Property.tutoring_end
    @day = Time.now.strftime("%a")
  end

end
