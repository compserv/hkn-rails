# Contains application-specific extensions to ActiveRecord::Base.
module ApplicationModel
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

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
    #
    # @param association [Symbol] #TODO fill me in
    # @param scope       [Symbol] #TODO fill me in
    # @return [ActiveRecord::Scope]
    def foreign_scope(association, scope)
      reflect_on_association(association).klass.public_send(scope, self, association)
    end

  end

end

ActiveRecord::Base.send(:include, ApplicationModel)
