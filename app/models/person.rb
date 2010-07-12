require 'net/ldap'

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

  has_one :candidate
  has_one :tutor
  has_many :committeeships
  has_and_belongs_to_many :groups
  has_many :rsvps
  
  validates :first_name,  :presence => true
  validates :last_name,   :presence => true
  # Username, password, and email validation is done by AuthLogic

  acts_as_authentic do |c|
    # Options go here if you have any
    c.validates_length_of_password_field_options :minimum => 8
  end

  def valid_ldap_or_password?(password)
    return valid_ldap?(password) || valid_password?(password)
  end

  def valid_ldap?(password)
    ldap = Net::LDAP.new( :host => LDAP_SERVER, :port => LDAP_SERVER_PORT )
    a = ldap.bind( :method => :simple, :username => "uid=#{username}, ou=people, dc=hkn, dc=eecs, dc=berkeley, dc=edu", :password => password )
    return a
  end
  
  def get_tutor
    if self.tutor.nil?
      self.tutor = Tutor.new
      self.tutor.availability = Availability.new
      self.tutor.save
      self.tutor.availability.save
    end
    return self.tutor
  end
  
  def fullname
    return first_name + " " + last_name
  end
end
