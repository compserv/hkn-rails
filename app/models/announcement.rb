# == Schema Information
#
# Table name: announcements
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  body       :string(255)
#  person_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Announcement < ActiveRecord::Base
  belongs_to :person
end
