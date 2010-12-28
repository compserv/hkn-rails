class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_current_user, :merge_messages, :check_authorizations
  layout 'application'

  #This is a bit of dynamic code that allows you to use methods like
  #authorize_foo to call authorize with a group as an argument. It might be
  #good to clean it up a little and put the matching in a separate class.
  # The idea comes from rails' dynamic finders.
  def respond_to?(method_id, include_private = false)
    case method_id.to_s
      when /^authorize_([_a-zA-Z]\w*)$/
        return true
      else
        super
    end
  end

  def method_missing(method_id, *arguments, &block)
    case method_id.to_s
      when /^authorize_([_a-zA-Z]\w*)$/
        group = $1
        self.send :authorize, group
      else
        super
    end
  end  

  def current_user=(user)
    @current_user = user
  end

  def auth=(auth)
    @auth = auth
  end

  #-----------------------------------------------------------------------
  # Private Methods
  #-----------------------------------------------------------------------
  private
  
  def get_current_user
    if UserSession.find
      @current_user ||= UserSession.find.person
    end
  end

  def merge_messages
    @messages ||= []
    @debug ||= []
    if flash[:notice]
      @messages << flash[:notice]
    end
  end

  def authorize(group_or_groups=nil)
    # group_or_groups must be either a single Group name or an array of Group names
    # If user is in any of the groups, then he has access
    groups = (group_or_groups.class == String) ? [group_or_groups] : group_or_groups
    if @current_user.nil?
      redirect_to :login, :notice => "Please log in to access this page.", :flash => {:referer => request.fullpath}
      return
    end
    unless groups.nil? or @current_user.admin? or @current_user.groups.map{|x| groups.include? x.name}.reduce{|x,y| x || y}
      redirect_to :root, :notice => "Insufficient privileges to access this page."
    end
  end

  def check_authorizations
    @auth ||= {}
    unless @current_user.nil?
      if @current_user.admin?
        @auth.default = true
      else
        @current_user.groups.each do |group|
          @auth[group.name] = true
        end
      end
      @auth['comms'] = @auth['cmembers'] || @auth['officers']
    end
  end
end
