class Slot < ActiveRecord::Base

  # ==== List of columns ====
  #   time    : Time
  #   tutors  : Tutor[]
  #   room    : Int
  #   changes : slot_change[]
  # =========================

  has_many :tutors
  has_many :slot_changes

  validate :valid_time_range

  def get_room()
    if room == 0 then
      "Cory"
    elsif room == 1 then
      "Soda"
    else
      "Undefined"
    end
  end

  def valid_time_range

  end
end
