#!/usr/bin/env ruby

# This script will import course information parsed from the online course 
# catalog (http://sis.berkeley.edu/catalog/gcc_view_req?p_dept_cd=EECS)
# into the system. It does not do anything if it finds a course that's
# already in the system. We may want to later add a few lines of code
# that updates information if the course already exists
#
# -richardxia

require "open-uri"

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../config/environment', __FILE__)

doc = Nokogiri::HTML(open("http://www.eecs.berkeley.edu/Faculty/Lists/list.shtml"))
table = doc.css("div#content table").first
rows = table.children
mode = :name
regular_name = nil

prof = {}
rows.each do |row|
  tds = row.children.filter("td")
  if tds.size > 1
    case mode
    when :name
      name = tds[1].at_css('a').inner_text.strip
      prof[:first_name] = name.split(' ').first
      prof[:last_name]  = name.split(' ').last
      regular_name = name.match(/^([\w-]*)\s+(\w\.\s+)*(\w[^\s]*)$/)
      #(prof[:first_name], prof[:last_name]) = name.match(/^([\w-]*)\s+(?:\w\.\s*)*(\w.*)$/)[1..-1]
      prof[:title] =  tds[1].children[3].inner_text.strip
      detail_page = "http://www.eecs.berkeley.edu" + tds[1].at_css('a').attr('href')
      anchor = Nokogiri::HTML(open(detail_page)).css('#leftcoltext').at_css('a')
      prof[:picture] = "http://www.eecs.berkeley.edu/Faculty/Photos/Homepages/"+detail_page.match(/\/([^\/]*).html$/)[1]
      prof[:home_page] = anchor.attr('href') unless anchor.blank? or anchor.inner_text != "Personal Homepage"
      mode = :info
    when :info
      office_phone_email = tds[2].children[0].inner_text.strip

      office_phone_email.split(',').map{|section| section.split(';')}.flatten.each do |field|
        if str = field.match(/^\s*(.*@.*)$/)
          prof[:email] = str[1]
        elsif str = field.match(/^\s*([0-9\-]*)$/)
          prof[:phone_number] = str[1]
        else
          prof[:office] = field
        end
      end

      trace = false
      interests = []
      tds[2].children.each do |node|
        case node.node_name
        when "strong"
          trace = (node.inner_text == "Research Interests:")
        when "br"
          trace = false
        else
          interests << node.inner_text if trace
        end
      end
      prof[:interests] = interests.join.strip
      prof[:private] = false

      if inst = Instructor.find(:first, :conditions => { :last_name => prof[:last_name], :first_name => prof[:first_name] })
        puts "Found existing entry for #{prof[:first_name]} #{prof[:last_name]}. Updating information."
        inst.update_attributes! prof
      else
        puts "Creating new entry for #{prof[:first_name]} #{prof[:last_name]}."
        puts "Warning: name has irregular format due to non-abbreviated middle string. Please update this entry's first and last names in the database manually." unless regular_name
        puts "Warning: Last name contains non-ASCII characters. Please manually update with ASCII characters." unless prof[:last_name].match(/^[a-zA-Z'-]*$/)
        Instructor.create!(prof)
      end
      prof = {}
      mode = :name
    end
  end
end
