class HomeController < ApplicationController
  def index
    @show_searcharea = true
    @tutoring_enabled = Property.tutoring_enabled
    @hours = Property.tutoring_start .. Property.tutoring_end
    @day = Time.now.strftime("%a")
    @tutoring_message = Property.tutoring_message
  end

end
