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
  #   failed_login_count  : integer 
  #   current_login_at    : datetime 
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

  attr_accessible :first_name
  attr_accessible :last_name
  attr_accessible :username
  attr_accessible :password
  attr_accessible :password_confirmation
  attr_accessible :email
  attr_accessible :phone_number
  attr_accessible :aim
  attr_accessible :date_of_birth
  attr_accessible :picture
  attr_accessible :private
  attr_accessible :local_address
  attr_accessible :perm_address
  attr_accessible :grad_semester

  validates :first_name,  :presence => true
  validates :last_name,   :presence => true

  module Validation
    module Regex
      Name = /\A[a-z\- ']+\z/i
    end
  end

  validates_format_of :first_name, :with => Validation::Regex::Name
  validates_format_of :last_name,  :with => Validation::Regex::Name
  # Username, password, and email validation is done by AuthLogic

  scope :current_candidates, lambda{ joins(:groups).where('groups.id' => Group.find_by_name('candidates')) }
  scope :current_comms, lambda{ joins(:groups).where('groups.id' => Group.find_by_name('comms')) }
  scope :alpha_last, lambda {order('last_name, first_name')}
  scope :alpha,      lambda {order('first_name, last_name')}

  acts_as_authentic do |c|
    # Options go here if you have any
    c.merge_validates_length_of_password_field_options :minimum => 8
    # Allows us to use the old password hashes. Upon successfully logging in,
    # the password hash will be automatically converted to SHA512
    c.transition_from_crypto_providers = DjangoSha1

    c.validates_length_of_login_field_options = {:within => 2..100}
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

  def phone_number
    return nil unless n = read_attribute(:phone_number) and not n.blank?
    n.gsub! /[^\d]/, ''
    "(#{n[0..2]}) #{n[3..5]}-#{n[6..9]}"
  end

  def current_election
      Election.current_semester.elected.where(:person_id => self.id).first
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

  def as_email
    return "\"#{fullname}\" <#{email}>"
  end

  # @return [Resume] this {Person}'s most recent resume
  def resume
    self.resumes.first
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

  def requested_challenges
    self.id ? Challenge.where(:officer_id => self.id) : Challenge.where(:id => nil) # dummy empty relation
  end

end
