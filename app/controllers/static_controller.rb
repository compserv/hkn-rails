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
    semester = params[:semester] || Property.semester
    season_map = {"sp" => "1", "su" => "2", "fa" => "3"}
    if semester =~ /^\w{2}\d{4}$/
      season = semester[0..1]
      year = semester[2..5]
      semester = year + season_map[season]
    end
    @year = semester[0..3]
    @season = case semester[4..4] when "1" then "Spring" when "2" then "Summer" when "3" then "Fall" end

    @next_semester = nil
    if semester != Property.semester
      if semester[4..4] == "1"
        @next_semester = "fa" + semester[0..3]
      elsif semester[4..4] == "3"
        @next_semester = "sp" + (semester[0..3].to_i + 1).to_s
      end
    end

    @prev_semester = nil
    if semester[4..4] == "3"
      @prev_semester = "sp" + semester[0..3]
    elsif semester[4..4] == "1"
      @prev_semester = "fa" + (semester[0..3].to_i - 1).to_s
    end

    the_officers = Committeeship.where(:semester => semester).where(:title => "officer")
    @no_data = the_officers.blank?
    @pres = the_officers.find_all_by_committee("pres").map{|x|x.person}
    @vp = the_officers.find_all_by_committee("vp").map{|x|x.person}
    @rsec = the_officers.find_all_by_committee("rsec").map{|x|x.person}
    @csec = the_officers.find_all_by_committee("csec").map{|x|x.person}
    @treas = the_officers.find_all_by_committee("treas").map{|x|x.person}

    @execs = [ ["President"] << "pres" << @pres , ["Vice President"] << "vp" << @vp , ["Recording Secretary"] << "rsec" << @rsec , ["Corresponding Secretary"] << "csec" << @csec  , ["Treasurer"] << "treas" << @treas ]

    exec_names = %w[pres vp rsec csec treas]

    committee_names = the_officers.map{|x| x.committee}.uniq
    committee_names.delete_if{|x| exec_names.include? x}
    committee_names.sort!

    committee_map = { 
      "act" => "Activities",
      "alumrel" => "Alumni Relations",
      "bridge" => "Bridge",
      "compserv" => "Computer Services",
      "deprel" => "Department Relations",
      "ejc" => "Engineering Joint Council",
      "examfiles" => "Exam Files",
      "indrel" => "Industrial Relations",
      "pub" => "Publicity",
      "serv" => "Service",
      "studrel" => "Student Relations",
      "tutoring" => "Tutoring",
    }

    @committees = []
    committee_names.each do |committee|
      committee_officers = the_officers.where(:committee => committee).map{|x| x.person}
      committee_struct = [
        committee_map[committee],
        committee,
        committee_officers,
      ]
      @committees << committee_struct
    end
  end
end
