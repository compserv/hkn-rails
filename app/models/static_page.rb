class StaticPage < ActiveRecord::Base
  belongs_to :parent, class_name: 'StaticPage'
end
