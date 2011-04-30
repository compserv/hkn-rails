class AddCommitteeToGroups < ActiveRecord::Migration
  def self.up

    add_column :groups, :committee, :boolean, :null => false, :default => false
    Group.reset_column_information

    # Transition some groups
    Group.find(:all, :conditions => {:name =>
    [
     "pres",    
     "vp",      
     "rsec",    
     "csec",    
     "treas",   
     "deprel",  
     "serv",    
     "indrel",  
     "bridge",  
     "act",     
     "compserv",
     "studrel", 
     "tutoring",
     "alumrel", 
     "alumadv", 
     "facadv"
    ]}).each do |g|
        g.update_attribute(:committee, true)
    end
  end

  def self.down
      remove_column :groups, :committee
  end
end
