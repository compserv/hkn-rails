class IndrelEventType < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  validates_presence_of :name

  def to_s
    name
  end
end
