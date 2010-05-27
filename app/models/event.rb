class Event < ActiveRecord::Base
  validates :name, :presence => true

  # Note on slugs: http://googlewebmastercentral.blogspot.com/2009/02/specify-your-canonical.html 

  def validate
    errors.add_to_base("Start date must be less than end date") unless start_time < end_time
  end
end
