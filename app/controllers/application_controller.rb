class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_current_user, :merge_messages
  layout 'application'
  
  private
  
  def get_current_user
    if UserSession.find
      @current_user = UserSession.find.person
    end
  end

  def merge_messages
    @messages ||= []
    if flash[:notice]
      @messages << flash[:notice]
    end
  end

  def authorize(group=nil)
    if @current_user.nil?
      redirect_to :login, :notice => "Please log in to access this page."
      return
    end
    unless group.nil? or @current_user.groups.include?(Group.find_by_name("superusers")) or @current_user.groups.map{|x| x.name}.include?(group)
      redirect_to :root, :notice => "Insufficient privileges to access this page."
    end
  end
end
