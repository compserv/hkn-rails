class HomeController < ApplicationController
  def index
    @show_searcharea = true
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @hours = prop.tutoring_start .. prop.tutoring_end
    @day = Time.now.strftime("%a")
    @tutoring_message = prop.tutoring_message
  end

end
