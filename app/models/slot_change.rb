class SlotChange < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   tutor_id   : integer 
  #   date       : datetime 
  #   add_sub    : integer 
  #   slot_id    : integer 
  #   created_at : datetime 
  #   updated_at : datetime 
  # =======================

  has_one :tutor

  validates :tutor, :presence => true
  validate :valid_add_sub

  def valid_add_sub
    errors[:add_sub] << "Must be either 0 (add) or 1 (subtract)" unless (add_sub == 0 or add_sub == 1)
  end

  def get_type()
    if type == 0 then
      "Add"
    elsif type == 1 then
      "Subtract"
    end
  end
end
