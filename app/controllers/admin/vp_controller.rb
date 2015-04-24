include Process

require 'json'
require 'open3'

class Admin::VpController < Admin::AdminController
  before_filter :authorize_vp

  def index
  end

  def committees
    @candidates = Candidate.approved.current.sort_by {|c| (c.person && c.person.last_name.downcase) || "zzz"  }
    cand_hash = {}
    @committee_out = ""
    @candidates.each{|cand| cand_hash[cand.person.id] = cand.committee_preferences}
    Open3.popen3("python -i ") do |stdin, stdout, stderr|
      input = JSON.dump(cand_hash)
      input = "{0:'CompServTutoringIndrelActivitiesStudRelBridgeService',
      1:'TutoringIndrelActivitiesStudRelBridgeServiceCompServ',
      2:'ServiceBridgeStudRelActivitiesIndrelTutoringCompServ',
      3:'BridgeServiceCompServTutoringIndrelActivitiesStudRel',
      4:'ActivitiesIndrelTutoringCompServServiceBridgeStudRel',
      5:'IndrelBridgeServiceStudRelActivitiesCompServTutoring',
      6:'CompServIndrelActivitiesStudRelTutoringBridgeService',
      7:'CompServTutoringIndrelActivitiesStudRelBridgeService',
      8:'ActivitiesIndrelTutoringCompServServiceBridgeStudRel'},
      'spots':{'CompServ':1,'Tutoring':1,'Indrel':2,
          'Activities':1,'StudRel':1,'Bridge':1,'Service':1}}"
      stdin.puts "import os; print(os.getcwd())"
      #stdin.puts "solve(split(parse('"+ input + "')))"
      stdin.puts "exit()"
      stdout.each_line { |line| @committee_out += "\n" + line}
      stdin.close
    end
  end
end
