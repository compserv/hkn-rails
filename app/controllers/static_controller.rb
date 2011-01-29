class StaticController < ApplicationController
  tocache = [:coursesurveys_how_to, :coursesurveys_info_profs, :coursesurveys_ferpa, :contact, :comingsoon, :yearbook, :slideshow]
  tocache.each {|a| caches_action a, :layout => true}
  
	def coursesurveys_how_to
	end
	
	def coursesurveys_info_profs
	end
	
	def coursesurveys_ferpa
  end
  
  def contact
  end
  
  def comingsoon
  end
  
  def yearbook
  end
  
  def slideshow
  end
end
