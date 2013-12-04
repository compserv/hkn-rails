class TutorSwap < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   slot_id       : integer 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  #   orig_tutor_id : integer 
  #   new_tutor_id  : integer 
  #   swap_date     : date 
  # =======================

  has_many :tutors
  has_one :slot

  # validates :tutors, :presence => true
  # validates :tutors, length: { is: 2 }
  # validates :slot, :presence => true
  
  # validate :check_tutors

  TUTOR_ERROR = "swapping tutors cannot be the same tutor"

  # checks to see if the two tutors are different
  def check_tutors(tutors)
    my_tutors = self.tutors
    if my_tutors[0] == my_tutors[1] then
      errors[:tutor] << TUTOR_ERROR
    end
  end

end
