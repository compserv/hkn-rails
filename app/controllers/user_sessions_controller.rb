class UserSessionsController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy

  private
  def use_recaptcha?
    session[:login_attempts] && session[:login_attempts] > 3
  end

  public

  def show
    redirect_to root_url
  end

  def new
    @hide_topbar = true
    @user_session = UserSession.new
    @referer = flash[:referer]
  end

  def create
    user = Person.find_by_username(params[:user_session][:username])
    @user_session = UserSession.new(params[:user_session])
    
    if user and user.approved
      if (use_recaptcha? ? verify_recaptcha(:model=>@user_session) : true) && @user_session.save
        flash[:notice] = "Login successful!"
        session[:login_attempts] = 0
        if params[:referer]
          redirect_to params[:referer]
          return
        else
          redirect_to root_url
          return
        end
      end
    end

    session[:login_attempts] ||= 0
    session[:login_attempts] += 1
    @use_captcha = true if use_recaptcha?

    flash[:notice] = "Login was unsuccessful."
    render :action => :new
    
  end

  def destroy
    current_user_session = UserSession.find
    current_user_session.destroy if current_user_session
    flash[:notice] = "Logout successful!"
    redirect_to login_url
  end
end
