class Availability < ActiveRecord::Base

  # ==== List of columns ====
  #   times          : Time[]
  #   tutor          : Tutor
  #   preferred_room : Int
  # =========================

  has_many :Time
  has_one :tutor

  validate :valid_times

  def get_preferred_room()
    if preferred_room == 0 then
      "Cory"
    elsif preferred_room == 1 then
      "Soda"
    else
      "Undefined"
    end
  end 

  def valid_times

  end
end
