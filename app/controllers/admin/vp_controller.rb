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
    @err = ""
    @candidates.each{|cand| cand_hash[cand.person.id] = cand.committee_preferences}
    Open3.popen3("python -i ../script/hungary") do |stdin, stdout, stderr|
      input = JSON.dump(cand_hash)
      stdin.puts "solve(split(parse('"+ input + "')))"
      stdin.puts "exit()"
      stdout.each_line { |line|
        line.sub(/[0-9]{1,}/) {|num| Person.find_by_id(num.to_i).full_name}
        @committee_out += "\n" + line}
      stderr.each_line { |line| @err += "\n" + line}
      stdin.close
    end
  end
end
