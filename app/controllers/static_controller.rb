class StaticController < ApplicationController
  tocache = [:coursesurveys_how_to, :coursesurveys_info_profs, :coursesurveys_ferpa, :contact, :comingsoon, :yearbook, :slideshow]
  tocache.each {|a| caches_action a, :layout => false}
  
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

  def officers
    @pres = Person.find_by_username("richardxia")
    @vp = Person.find_by_username("byang")
    @rsec = Person.find_by_username("tmagrino")
    @treas = Person.find_by_username("ronagesh")
    @csec = Person.find_by_username("awong")
    @deprel = Person.find_by_username("elevin")

    @serv = %w(rajat kathysun).map {|u| Person.find_by_username(u)}
    @indrel = %w(rlan sameetr akashgupta sren).map {|u| Person.find_by_username(u)}
    @bridge = %w(ykim daiweili alexsun).map {|u| Person.find_by_username(u)}
    @act = %w(ystephie seshadri amatsukawa).map {|u| Person.find_by_username(u)}
    @compserv = %w(awygle amber akim adegtiar).map {|u| Person.find_by_username(u)}
    @studrel = %w(mmatloob rpoddar maxfeldman).map {|u| Person.find_by_username(u)}
    @tutoring = %w(erictzeng tonydear dsadigh chongyang).map {|u| Person.find_by_username(u)}
    @alumrel = %w(bdong).map {|u| Person.find_by_username(u)}

    @committees = [ ["Service"] << @serv, ["Industrial Relations"] << @indrel, ["Bridge"] << @bridge, ["Activities"] << @act, ["Computing Services"] << @compserv, ["Student Relations"] << @studrel, ["Tutoring"] << @tutoring, ["Alumni Relations"] <<@alumrel ]

    @execs = [ ["President"] << @pres, ["Vice President"] << @vp, ["Recording Secretary"] << @rsec, ["Treasurer"] << @treas, ["Corresponding Secretary"] << @csec, ["Department Relations"] << @deprel ]

    @committees.each {|g| g.last.compact!}
  end
end
