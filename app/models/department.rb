class Department < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   abbr       : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  has_many :courses

  validates :name, :presence => true
  validates :abbr, :presence => true
  
  #This is a mapping of some proper abbreviations to their commonly used
  #informal abbreviations
  #
  @@nice_abbrs = {
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
    
#  class << self
#    attr_reader :nice_abbrs
#  end

  def nice_abbrs
    # Sometimes abbr is like 'EE' already..
    # We'll dynamically fix this.
    @@nice_abbrs[abbr] || begin
        @@nice_abbrs.each_pair do |proper, informals|
            if informals.include? abbr then
                update_attribute(:abbr, proper)
                return informals
            end
        end # each_pair
        return [abbr]   # fallback
    end
  end

  def to_s
    name
  end

  def Department.find_by_nice_abbr(abbr)
    abbr.upcase!
    @@nice_abbrs.each_pair do |proper, informals|
      if informals.include? abbr
        abbr = proper
        break
      end
    end
    d = find_by_abbr(abbr)
    return d unless d.nil?
    # Didn't find one, perhaps abbreviations are stored wrong.. try to fix them
    Department.all.each {|d| d.nice_abbrs}
    find_by_abbr(abbr)
  end
end
