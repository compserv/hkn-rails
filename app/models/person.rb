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
  #   picture             : string 
  #   private             : boolean 
  #   local_address       : string 
  #   perm_address        : string 
  #   grad_semester       : string 
  # =======================

  has_one :candidate
  has_one :tutor
  has_many :committeeships
  has_and_belongs_to_many :groups
  has_many :rsvps, :dependent => :destroy
  has_many :challenges
  has_one :suggestion

  validates :first_name,  :presence => true
  validates :last_name,   :presence => true
  # Username, password, and email validation is done by AuthLogic

  acts_as_authentic do |c|
    # Options go here if you have any
    c.merge_validates_length_of_password_field_options :minimum => 8
    # Allows us to use the old password hashes. Upon successfully logging in,
    # the password hash will be automatically converted to SHA512
    c.transition_from_crypto_providers = DjangoSha1
  end

  def valid_ldap_or_password?(password)
    return valid_ldap?(password) || valid_password?(password)
  end

  def valid_ldap?(password)
    ldap = Net::LDAP.new( :host => LDAP_SERVER, :port => LDAP_SERVER_PORT )
    a = ldap.bind( :method => :simple, :username => "uid=#{username}, ou=people, dc=hkn, dc=eecs, dc=berkeley, dc=edu", :password => password )
    return a
  end

  #Gets or creates the tutor object for a person.
  #
  def get_tutor
    if self.tutor.nil?
      self.tutor = Tutor.new
      self.tutor.save
    end
    return self.tutor
  end
  
  #Returns the person's full name
  #
  def fullname
    return first_name + " " + last_name
  end

  #Returns the person's first name and last initial
  #
  def abbr_name
    return first_name + " " + last_name[0..0]
  end

  def to_s
    return fullname
  end

  def in_group?(group)
    if group.class == String
      group = Group.find_by_name(group)
    end
    groups.include?(group)
  end

  # If person is in ANY group in the list, this returns true
  def in_groups?(groups)
    groups.map{|group| in_group?(group)}.reduce{|x,y| x||y}
  end

  def admin?
    in_group? "superusers"
  end

  def status
    current_committeeship = committeeships.find_by_semester(Property.semester)
    if current_committeeship.nil?
      if groups.include? Group.find_by_name("members")
        "Member"
      elsif groups.include? Group.find_by_name("candidates")
        "Candidate"
      else
        "Person"
      end
    else
      current_committeeship.nice_position
    end
  end
end
