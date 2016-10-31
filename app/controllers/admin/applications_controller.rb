class Admin::ApplicationsController < ApplicationController

  before_filter :authorize_vp

  def index
  end

  def byperson
    @candidates = cands

    respond_to do |format|
      format.html
      format.csv  {render layout: false}
    end
  end

  def bycommittee
    @mapping = cands.group_by {|c| c.committee_preferences and c.committee_preferences.split.first}

    respond_to do |format|
      format.html
      format.csv   {render layout: false}
    end
  end

  def byperson_without_application
    @candidates = cands.reject {|c| c.committee_preferences}

    respond_to do |format|
      format.html
      format.csv  {render layout: false}
    end
  end

private
  def cands
    Candidate.approved.current.sort_by {|c| (c.person && c.person.last_name.downcase) || "zzz"  }
  end

end
