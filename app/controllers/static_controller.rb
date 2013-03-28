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

  def cmembers
    # Get the most recent semester
    @semester = params[:semester] || Election.maximum(:semester)
    # Using the semester, get the committeeships, sorted by committee
    cships = Committeeship.semester(@semester).cmembers.sort_by do |c|    
      c.committee
    end.ordered_group_by(&:committee)
    # Group cships by committee
    @committeeships = cships.group_by do |c_ary|
      :committees
    end
    # If @committeeships[:committees] is null, make it empty
    @committeeships[:committees] ||= {}
  end


  def officers
    @semester = params[:semester] || Election.maximum(:semester)
    
    cships = Committeeship.semester(@semester).officers.sort_by do |c|
      if c.exec?  # exec position
        [0, Committeeship::Execs.find_index(c.committee)].join
      else        # normal committee
        [1, c.committee].join
      end
    end.ordered_group_by(&:committee)

    @committeeships = cships.group_by do |c_ary|  # c_ary = [committee_name, [cships]]
      Committeeship::Execs.include?(c_ary[0])  ?  :execs  :  :committees
    end

    [:execs, :committees].each {|s| @committeeships[s] ||= {}}   # NPEs are bad
  end

end
