class UserSessionsController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy

  #ssl_required :new, :create, :destroy

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
    return redirect_to login_path unless params[:user_session]

    user = Person.find_by_username(params[:user_session][:username])
    @user_session = UserSession.new(params[:user_session])

    # Three cases:
    # 1) Successful login
    # 2) Successful credentials but account not approved
    # 3) Failed login
    
    if user and (use_recaptcha? ? verify_recaptcha(:model=>@user_session) : true) && @user_session.save
      flash[:notice] = "Login successful!"
      session[:login_attempts] = 0
      if params[:referer]
        redirect_to params[:referer]
      else
        redirect_to root_url
      end
    elsif @user_session.errors[:base].size == 1 and @user_session.errors[:base].include? "Your account is not approved"
      @messages << "Your user account has not been approved yet. Please wait at least 24 hours for your account to be approved."
      render :action => :new
    else
      session[:login_attempts] ||= 0
      session[:login_attempts] += 1
      @use_captcha = true if use_recaptcha?

      @messages << "Login was unsuccessful."
      render :action => :new
    end
  end

  def destroy
    current_user_session = UserSession.find
    current_user_session.destroy if current_user_session
    current_user = nil  # see applicationcontroller
    flash[:notice] = "Logout successful!"
    redirect_to login_url
  end
end
