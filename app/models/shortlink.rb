class Shortlink < ActiveRecord::Base
  validates :in_url, :out_url, :http_status, :person_id, presence: true
  validates :in_url, uniqueness: true
  validates_format_of :in_url, without: /\.|\//
  belongs_to :person
end
