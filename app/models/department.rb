class Department < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   abbr       : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  validates :name, :presence => true
  validates :abbr, :presence => true
  
  #This is a mapping of some proper abbreviations to their commonly used
  #informal abbreviations
  #
  @nice_abbrs = {
    "ASTRON" => ["ASTRO"],
    "BIOLOGY" => ["BIO"],
    "BIO ENG" => ["BIOE"],
    "UGBA" => ["BA"],
    "CHM ENG" => ["CHEME"],
    "CIV ENG" => ["CIVE", "CEE", "CE", "CIVIL ENGINEERING"],
    "COG SCI" => ["COGSCI"],
    "COMPSCI" => ["CS"],
    "EL ENG" => ["EE"],
    "ENGIN" => ["E", "ENG", "ENGINEERING"],
    "HISTORY" => ["HIST"], #not actually used
    "IND ENG" => ["IEOR"],
    "INTEGBI" => ["IB"],
    "LINGUIS" => ["LING"], #not actually used
    "MAT SCI" => ["MSE"],
    "MEC ENG" => ["ME"],
    "MCELLBI" => ["MCB"],
    "PHYSICS" => ["PHYS"],
    "POL SCI" => ["POLISCI"], #not actually used
    "STAT" => ["STAT", "STATS"],
    "ECON" => ["ECONOMICS"],
    "UGIS" => ["IDS"],
    "ENV SCI"  => ["ENV SCI", "ENVIR SCI"],
    "ENVECON"  => ["ENVECON", "ENVIR ECON & POLICY"],
    }
    
  class << self
    attr_reader :nice_abbrs
  end

  def nice_abbrs
    Department.nice_abbrs[abbr]
  end

  def Department.find_by_nice_abbr(abbr)
    abbr.upcase!
    @nice_abbrs.each_pair do |proper, informals|
      if informals.include? abbr
        abbr = proper
      end
    end
    find_by_abbr(abbr)
  end
end
