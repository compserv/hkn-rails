class Shortlink < ActiveRecord::Base
  validates :in_url, :out_url, :http_status, :person_id, :presence => true
  validates :in_url, :uniqueness => true
  belongs_to :person
end
