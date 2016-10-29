# == Schema Information
#
# Table name: badges
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Badge < ActiveRecord::Base
  has_and_belongs_to_many :people

  def picture_url
    return "/images/badges/" + url
  end
end
