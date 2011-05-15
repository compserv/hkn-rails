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
  #   approved            : boolean 
  # =======================

  has_one :candidate, :dependent => :destroy
  has_one :alumni, :dependent => :destroy
  has_one :tutor, :dependent => :destroy
  has_many :committeeships, :dependent => :destroy
  has_and_belongs_to_many :groups
  has_many :rsvps, :dependent => :destroy
  has_many :events, :through => :rsvps
  has_many :challenges, :through => :candidate
  has_many :resumes, :dependent => :destroy
  has_one :suggestion
  has_and_belongs_to_many :coursesurveys
  has_and_belongs_to_many :badges
  has_many :elections, :dependent => :destroy

  validates :first_name,  :presence => true
  validates :last_name,   :presence => true
  # Username, password, and email validation is done by AuthLogic

  scope :current_candidates, lambda{ joins(:groups).where('groups.id' => Group.find_by_name('candidates')) }
  scope :current_comms, lambda{ joins(:groups).where('groups.id' => Group.find_by_name('comms')) }

  acts_as_authentic do |c|
    # Options go here if you have any
    c.merge_validates_length_of_password_field_options :minimum => 8
    # Allows us to use the old password hashes. Upon successfully logging in,
    # the password hash will be automatically converted to SHA512
    c.transition_from_crypto_providers = DjangoSha1
  end

  def change_username(opts)
      new_uname, pw = opts[:username], opts[:password]
      return false unless new_uname && pw
      unless self.valid_password?(pw, true)
          self.errors.add :password, 'is invalid'
          return false
      end
      self.username = new_uname
      self.password = pw
      self.password_confirmation = pw
      return self.valid?
  end
  
  def picture(guess=false)
    # HACK: dynamically guesses user's picture
    p = method_missing(:picture)
    p = p.blank? && guess ? "https://hkn.eecs.berkeley.edu/files/officerpics/#{username}.png" : p
    #p.gsub!(/^http/, 'https') if p =~ /^http:\/\/hkn.eecs.berkeley.edu/
    p
  end

  def full_name
    first_name + " " + last_name
  end

  def current_election
      self.elections.where(:semester => Property.current_semester).elected.limit(1).first
      #Election.find_by_person_id_and_semester self.id, Property.current_semester
  end

  def valid_ldap_or_password?(password)
    return valid_password?(password) || valid_ldap?(password)
  end

  def valid_ldap?(password)
    begin
      ldap = Net::LDAP.new( :host => LDAP_SERVER, :port => LDAP_SERVER_PORT )
      a = ldap.bind( :method => :simple, :username => "uid=#{username}, ou=people, dc=hkn, dc=eecs, dc=berkeley, dc=edu", :password => password )
    rescue Net::LDAP::LdapError
      return false
    end
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

  def join_groups(gnames)
    self.groups |= Group.find_all_by_name([*gnames])
  end
  def join_groups!(gnames)
    self.join_groups gnames
    self.save
  end
end
