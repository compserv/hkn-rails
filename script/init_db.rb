#!/usr/bin/env ruby

# This script will initialize database with various entries if they are not
# already in the database. You should run this if you are grabbing a fresh
# copy of the source code and are not importing the existing database.
#
# -richardxia

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load into the production database.
require File.expand_path('../../config/environment', __FILE__)

# Create Groups
groups = [
  {"name"=>"superusers","description"=>"Admin"},
  {"name"=>"members",   "description"=>"Members"},
  {"name"=>"candidates","description"=>"Candidates"},
  {"name"=>"comms",     "description"=>"Committee Members and Officers"},
  {"name"=>"pres",      "description"=>"President"},
  {"name"=>"vp",        "description"=>"Vice President"},
  {"name"=>"rsec",      "description"=>"Recording Secretary"},
  {"name"=>"csec",      "description"=>"Corresponding Secretary"},
  {"name"=>"treas",     "description"=>"Treasury"},
  {"name"=>"deprel",    "description"=>"Department Relations"},
  {"name"=>"serv",      "description"=>"Service"},
  {"name"=>"indrel",    "description"=>"Industrial Relations"},
  {"name"=>"bridge",    "description"=>"Bridge"},
  {"name"=>"act",       "description"=>"Activities"},
  {"name"=>"compserv",  "description"=>"Computer Services"},
  {"name"=>"studrel",   "description"=>"Student Relations"},
  {"name"=>"tutoring",  "description"=>"Tutoring"},
  {"name"=>"alumrel",   "description"=>"Alumni Relations"},
  {"name"=>"alumadv",   "description"=>"Alumni Advisor"},
  {"name"=>"facadv",    "description"=>"Faculty Advisor"},
]

groups.each do |group|
  unless Group.find_by_name(group["name"])
    puts "Did not find \"#{group["name"]}\" group. Creating now"
    Group.create!(group)
  end
end
