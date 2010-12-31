class Instructor < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   last_name    : string 
  #   picture      : string 
  #   title        : string 
  #   phone_number : string 
  #   email        : string 
  #   home_page    : string 
  #   interests    : text 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  #   private      : boolean 
  #   office       : string 
  #   first_name   : string 
  # =======================

  has_many :coursesurveys
  has_and_belongs_to_many :klasses
  has_and_belongs_to_many :tad_klasses, { :class_name => "Klass", :join_table => "klasses_tas" }

  def full_name
    first_name + " " + last_name
  end

  # Reverse order
  def full_name_r
    last_name + ", " + first_name
  end
  
  def ta?
    title =~ /TA/i
  end

  def Instructor.find_by_name(first_name, last_name)
    Instructor.find(:first, :conditions => { :first_name => first_name, :last_name => last_name} )
  end

end
