class CommitteePreference < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   group_id     : integer 
  #   candidate_id : integer 
  #   rank         : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  # =======================

  belongs_to :candidate
  belongs_to :group

  validates :group, :presence => true
  validates :candidate, :presence => true
end
