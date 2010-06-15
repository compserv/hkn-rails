class SlotChange < ActiveRecord::Base
 
  # === List of columns ===
  #   tutor        : Tutor
  #   date         : Time
  #   add/subtract : ???
  # =======================

  has_one :tutor

  validate :valid_time

  def valid_time

  end
end
