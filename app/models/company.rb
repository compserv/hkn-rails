# == Schema Information
#
# Table name: companies
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  address             :text
#  website             :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  comments            :text
#  persistence_token   :string(255)      default(""), not null
#  single_access_token :string(255)      default(""), not null
#

class Company < ActiveRecord::Base
  has_many  :contacts
  has_many  :transactions
  validates_presence_of :name

  acts_as_authentic do |config|
    config.login_field = :name
  end

  scope :ordered, -> { order('name ASC') }

  def to_s
    name
  end
end
