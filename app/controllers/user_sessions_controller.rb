class UserSessionsController < ApplicationController
  #before_filter :require_no_user, only: [:new, :create]
  #before_filter :require_user, only: :destroy

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
    @user_session = UserSession.new(user_session_params)

    # Three cases:
    # 1) Successful login
    # 2) Successful credentials but account not approved
    # 3) Failed login

    if user and (use_recaptcha? ? verify_recaptcha(model: @user_session) : true) && @user_session.save
      flash[:notice] = "Login successful!"
      session[:login_attempts] = 0
      if params[:referer]
        redirect_to params[:referer]
      else
        redirect_to root_url
      end
    elsif @user_session.errors[:base].size == 1 and @user_session.errors[:base].include? "Your account is not approved"
      @messages << "Your user account has not been approved yet. Please wait at least 24 hours for your account to be approved."
      render action: :new
    else
      session[:login_attempts] ||= 0
      session[:login_attempts] += 1
      @use_captcha = true if use_recaptcha?

      @messages << "Login was unsuccessful."
      render action: :new
    end
  end

  def destroy
    current_user_session = UserSession.find
    if current_user_session
      @current_user.update_attribute(:current_login_at, nil)
      current_user_session.destroy
    end
    current_user = nil  # see applicationcontroller.current_user=
    flash[:notice] = "Logout successful!"
    redirect_to login_url
  end

  def reauthenticate
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def reauthenticate_post
    @success = !!(@real_current_user && @real_current_user.valid_ldap_or_password?(params[:password]))
    if @success
      current_user_session.save
      render js: "puts('Thanks. You can run superuser things now.');"
    else
      render js: "puts('Sorry, try again.'); reauthenticate();"
    end
  end

  private

    def user_session_params
      params.require(:user_session).permit(
        :username,
        :password,
        :remember_me
      )
    end

end
