# == Schema Information
#
# Table name: calnet_users
#
#  id                        :integer          not null, primary key
#  uid                       :string(255)
#  name                      :string(255)
#  authorized_course_surveys :boolean
#  created_at                :datetime
#  updated_at                :datetime
#

class CalnetUser < ActiveRecord::Base
end
