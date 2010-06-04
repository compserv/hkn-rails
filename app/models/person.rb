class Person < ActiveRecord::Base

  # === List of columns ===
  #   id                  : integer 
  #   first_name          : string 
  #   last_name           : string 
  #   username            : string 
  #   email               : string 
  #   crypted_password    : string 
  #   password_salt       : string 
  #   persistence_token   : string 
  #   single_access_token : string 
  #   perishable_token    : string 
  #   phone_number        : string 
  #   aim                 : string 
  #   date_of_birth       : date 
  #   created_at          : datetime 
  #   updated_at          : datetime 
  # =======================

  acts_as_authentic do |c|
    # Options go here if you have any
  end

end
