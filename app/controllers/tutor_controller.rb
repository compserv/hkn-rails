class TutorController < ApplicationController

  caches_action :schedule, :layout => false
    
  def schedule
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @tutoring_message = prop.tutoring_message
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = prop.tutoring_start .. prop.tutoring_end
    @rows = ["Hours"] + @hours.to_a
  end

end
