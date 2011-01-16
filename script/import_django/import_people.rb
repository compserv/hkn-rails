#!/usr/bin/env ruby
#
# TODO: Figure out if we want to store the following info:
# * Address
# * Graduating semester (this is probably a yes)
# * Privacy (we probably want to implement this)
# 
# Also figure out how we want to do other stuff
# * Officership/candidateship/cmembership
# * Pictures
# * Grad student?

require File.expand_path('../../../config/environment', __FILE__)

f = File.open('dumps/user.json', 'r')
users = ActiveSupport::JSON::decode(f)
f = File.open('dumps/person.json', 'r')
people = ActiveSupport::JSON::decode(f)
f = File.open('dumps/extendedinfo.json', 'r')
extendedinfo = ActiveSupport::JSON::decode(f)

people.each do |id, person|
  user = users[person['user_ptr_id'].to_s]
  info = extendedinfo[id.to_s]
  next if user.blank?

  new_person = {}
  new_person['username']         = user['username']
  new_person['first_name']       = user['first_name']
  new_person['last_name']        = user['last_name']
  new_person['email']            = user['email']
  new_person['phone_number']     = person['phone']
  new_person['aim']              = info['aim_sn']

  # Privacy level of 3 means any registered user can view it. Since we only
  # have two privacy levels on the new site, we just set 'private' to true
  # if their existing privacy level was greater than 3
  privacy = false
  if !person['privacy'].nil?
    person['privacy'].each_value do |x|
      privacy ||= (x > 3)
    end
  end
  new_person['private']          = privacy
  #new_person['date_of_birth']    = 

  # Temporary password to let authlogic do its magic
  tmp_passwd = ActiveSupport::SecureRandom.hex(16)
  new_person['password'] = tmp_passwd
  new_person['password_confirmation'] = tmp_passwd
  p = Person.new(new_person)
  p.save()

  if p.valid?
    # Update with old password hash
    update_person = {}
    if not user['password'].blank? and user['password'] != '!'
      passwd = user['password'].split('$')
      update_person['crypted_password'] = passwd[2]
      update_person['password_salt'] = passwd[1]
    end
    p.update_attributes(update_person)

    if p.valid?
      puts "Imported " + user['username']
    else
      puts "Invalid password hash: " + user['username']
      puts p.errors
      p.delete
    end
  else
    puts "Invalid person: " + user['username']
    puts p.errors
    p.delete
  end

  # Member/candidate groups
  # ANONYMOUS = 0                                                                                  
  # REGISTERED = 3                                                                                 
  # EXCANDIDATE = 5
  # CANDIDATE = 10
  # MEMBER = 15                                                                                    
  # FOGIE = 20                                                                                     
  # EXOFFICER = 20                                                                                 
  # OFFICER = 25

  if person['member_type'] >= 15
    p.groups << Group.find_by_name('members')
    p.groups << Group.find_by_name('candplus')
  end

  if [5, 10].include? person['member_type']
    p.groups << Group.find_by_name('candidates')
    p.groups << Group.find_by_name('candplus')
  end

  if person['is_superuser']
    p.groups << Group.find_by_name('superusers')
  end
end
