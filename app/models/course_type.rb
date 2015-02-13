class CourseType < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   chart_pref_x  : float 
  #   chart_pref_y  : float 
  #   color         : string 
  #   name          : string 
  # =======================

  has_many :courses
  
  validates :chart_pref_x, :presence => true
  validates :chart_pref_y, :presence => true
  validates :color, :presence => true
  validates :name, :presence => true
end
