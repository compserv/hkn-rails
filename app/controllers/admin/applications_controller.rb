class Admin::ApplicationsController < ApplicationController

  before_filter :authorize_vp

  def index
  end

  def byperson
    @candidates = cands
  end

  def bycommittee
    @mapping = cands.group_by {|c| c.committee_preferences and c.committee_preferences.split.first}
  end

private
  def cands
    Candidate.current.sort_by {|c| (c.person && c.person.last_name.downcase) || "zzz"  }
  end

end
