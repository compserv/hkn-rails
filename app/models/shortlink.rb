# == Schema Information
#
# Table name: shortlinks
#
#  id          :integer          not null, primary key
#  in_url      :string(255)
#  out_url     :text
#  http_status :integer          default(301)
#  person_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Shortlink < ActiveRecord::Base
  validates :in_url, :out_url, :http_status, :person_id, presence: true
  validates :in_url, uniqueness: true
  # Don't allow fake redirects of important files, even if the rails default behavior changes.
  validates_format_of :in_url, without: /\.|\//
  belongs_to :person

  def own?(current_user, auth)
    person == current_user || auth['superuser']
  end
end
