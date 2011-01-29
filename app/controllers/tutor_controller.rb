class TutorController < ApplicationController

  caches_action :schedule, :layout => true
    
  def schedule
    prop = Property.get_or_create
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = prop.tutoring_start .. prop.tutoring_end
    @rows = ["Hours"] + @hours.to_a
  end

end
