class EventType < ActiveRecord::Base

  # === List of columns ===
  #   id   : integer 
  #   name : string 
  # =======================

  validates :name, :presence => true

  # Crappy pun for changing the name into a valid CSS class identifier
  def classify
    name.gsub(/\s/, '-').downcase
  end
end
