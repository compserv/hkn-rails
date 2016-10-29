# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  phone      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#  comments   :text
#  cellphone  :string(255)
#

class Contact < ActiveRecord::Base
  belongs_to  :company
  validates_presence_of :name, :email

  def to_s
    name
  end
end
