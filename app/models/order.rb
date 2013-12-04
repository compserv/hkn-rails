class Order < ActiveRecord::Base

  # === List of columns ===
  #   id              : integer 
  #   card_id         : integer 
  #   ip_address      : string 
  #   first_name      : string 
  #   last_name       : string 
  #   card_type       : string 
  #   card_expires_on : date 
  #   created_at      : datetime 
  #   updated_at      : datetime 
  # =======================

  attr_accessible :card_id, :ip_address, :first_name, :last_name, :card_type, :card_expires_on
end
