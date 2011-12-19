# This is meant to be an abstract class that all models inherit from. Define
# any methods that all models will inherit here.
class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true

  class << self
    # This allows you to chain an associated model's scope. It requires that the
    # foreign model's scope method be defined with the function prototype:
    # (ActiveRecord::Relation, association_name)
    #
    # Example: 
    # If we have the query to find all Users with posts that have approved
    # comments:
    #   User.joins(:posts => :comments).where(:comments => {:approved => true})
    # We could define the :approved_scope_helper scope in Post:
    #   class Post
    #     scope :approved, approved_scope_helper
    #     def self.approved_scope_helper(query=self, join_name=nil)
    #       join = {:post => :comments}
    #       join = {join_name => join} unless query == self
    #       query.joins(join).where(:comments => {:approved => true})
    #     end
    #   end
    # And use it in a foreign model like this:
    #   User.foreign_scope(:posts, :approved_scope_helper)
    def foreign_scope(association, scope)
      reflect_on_association(association).klass.public_send(scope, self, association)
    end
  end
end
