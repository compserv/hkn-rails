# == Schema Information
#
# Table name: people
#
#  id                  :integer          not null, primary key
#  first_name          :string(255)      not null
#  last_name           :string(255)      not null
#  username            :string(255)      not null
#  email               :string(255)      not null
#  crypted_password    :string(255)      not null
#  password_salt       :string(255)      not null
#  persistence_token   :string(255)      not null
#  single_access_token :string(255)      not null
#  perishable_token    :string(255)      not null
#  phone_number        :string(255)
#  aim                 :string(255)
#  date_of_birth       :date
#  created_at          :datetime
#  updated_at          :datetime
#  picture             :string(255)
#  private             :boolean          default(TRUE), not null
#  local_address       :string(255)      default("")
#  perm_address        :string(255)      default("")
#  grad_semester       :string(255)      default("")
#  approved            :boolean
#  failed_login_count  :integer          default(0), not null
#  current_login_at    :datetime
#  mobile_carrier_id   :integer
#  sms_alerts          :boolean          default(FALSE)
#  reset_password_link :string(255)
#  reset_password_at   :datetime
#  graduation          :string(255)
#

class Person < ActiveRecord::Base
  has_one :candidate, dependent: :destroy
  has_one :alumni, dependent: :destroy
  has_one :tutor, dependent: :destroy
  has_many :committeeships, dependent: :destroy
  has_and_belongs_to_many :groups
  has_many :rsvps, dependent: :destroy
  has_many :events, through: :rsvps
  has_many :challenges, through: :candidate
  has_many :resumes, dependent: :destroy
  has_one :suggestion
  has_and_belongs_to_many :coursesurveys
  has_and_belongs_to_many :badges
  has_many :elections, dependent: :destroy
  has_many :shortlinks
  belongs_to :mobile_carrier

  validates :first_name,  presence: true
  validates :last_name,   presence: true

  module Validation
    module Regex
      Https = /\A(https:\/\/|\/).*\z/i
      BerkeleyEmail = /@berkeley\.edu\z/i
      HKNEmail = /@hkn\.eecs\.berkeley\.edu\z/i
    end
  end

  validates_format_of :picture,    with: Validation::Regex::Https,
                                   allow_nil: true,
                                   allow_blank: true
  validates_format_of :email,      with: Validation::Regex::HKNEmail,
                                   message: 'must be an HKN Gmail using the hkn.eecs domain'

  # Username, password, and email validation is done by AuthLogic

  scope :current_candidates, lambda{ joins(:groups).where('groups.id' => Group.where(name: 'candidates').first) }
  scope :current_comms, lambda{ joins(:groups).where('groups.id' => Group.where(name: 'comms').first) }
  scope :alpha_last, lambda {order('last_name, first_name')}
  scope :alpha,      lambda {order('first_name, last_name')}

  acts_as_authentic do |c|
    # Explicitly use SCrypt (it is the default)
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt

    # Options go here if you have any
    c.merge_validates_length_of_password_field_options minimum: 8
    # Allows us to use the old password hashes. Upon successfully logging in,
    # the password hash will be automatically converted to SHA512
    c.transition_from_crypto_providers = DjangoSha1

    c.validates_length_of_login_field_options = { within: 2..100 }
  end

  # Sunspot
  searchable do
    text :first_name
    text :last_name
    text :username
    text :email
    text :first_name, as: 'first_name_text_ngram'
    text :last_name, as: 'last_name_text_ngram'
    text :username, as: 'username_text_ngram'
    text :email, as: 'email_text_ngram'
  end
  # end sunspot

  def first_name=(first_name)
    write_attribute(:first_name, first_name.strip)
  end

  def last_name=(last_name)
    write_attribute(:last_name, last_name.strip)
  end

  def username=(username)
    write_attribute(:username, username.strip)
  end

  def current_officer?
    titles = committeeships.where(semester: Property.semester)
                           .collect(&:title)
                           .uniq
    titles.include? "officer"
  end

  def current_cmember?
    titles = committeeships.where(semester: Property.semester)
                           .collect(&:title)
                           .uniq
    titles.include? "cmember" or titles.include? "assistant"
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

  def full_name
    first_name + " " + last_name
  end

  def phone_number
    return nil unless n = read_attribute(:phone_number) and not n.blank?
    n.gsub! /[^\d]/, ''
    if n.length == 10
      "(#{n[0..2]}) #{n[3..5]}-#{n[6..9]}"
    else
      n
    end
  end

  def phone_number_is_valid?
    phone_number_compact.size == 10
  end

  def phone_number_compact
    return "" unless n = read_attribute(:phone_number) and not n.blank?
    n.gsub /[^\d]/, ''
  end

  def sms_email_address
    return "" unless phone_number_is_valid? and not mobile_carrier.blank?
    "#{phone_number_compact}#{mobile_carrier.sms_email}"
  end

  # Sends an SMS message with the provided text if the user has sms_alerts enabled
  def send_sms!(msg)
    return false unless sms_alerts and phone_number_is_valid? and not mobile_carrier.blank?
    PersonMailer.send_sms(self, msg).deliver
  end

  def current_election
      Election.current_semester.elected.where(person_id: self.id).first
  end

  def last_election
    self.elections.elected.ordered.last
  end

  def needs_to_fill_out_election?
    l = last_election
    l and Property.end_of_semester? and l.semester == Property.current_semester and !l.filled_out?
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
      group = Group.where(name: group).first
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
    current_committeeship = committeeships.where(semester: Property.semester).first
    if current_committeeship.nil?
      if groups.include? Group.where(name: "members").first
        "Member"
      elsif groups.include? Group.where(name: "candidates").first
        "Candidate"
      else
        "Person"
      end
    else
      current_committeeship.nice_position
    end
  end

  def join_groups(gnames)
    self.groups |= Group.where(name: [*gnames])
  end
  def join_groups!(gnames)
    self.join_groups gnames
    self.save
  end

  def requested_challenges
    self.id ? Challenge.where(officer_id: self.id) : Challenge.where(id: nil) # dummy empty relation
  end

end
