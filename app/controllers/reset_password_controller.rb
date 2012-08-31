class ResetPasswordController < ApplicationController

  def reset_password
  end

  def reset_password_post
    @person = Person.find_by_username(params[:username])
    if @person
      @person.reset_password_link = SecureRandom.hex
      @person.reset_password_at = DateTime.current
      @person.save!
      ResetPasswordMailer.reset_password(@person).deliver 
      redirect_to(login_path, :notice => "Instructions for resetting your password have been sent to your email address.") and return
    else
      redirect_to(reset_password_path, :notice => "Sorry, no such user exists.")
    end 
  end

  def reset_password_confirm
    redirect_to login_path and return unless params[:temp]
    link = params[:temp]
    @person = valid_reset_password_link?(link)
    if !@person
      redirect_to(login_path, :notice => "The page you're looking for can't be found.")
    elsif reset_password_expired?(@person.reset_password_at)
      redirect_to(login_path, :notice => "The page you have requested is no longer available.") and return
    end
  end

  def reset_password_confirm_post
    @person = Person.find_by_id(params[:person])
    @person.password = params[:password][:new]
    @person.password_confirmation = params[:password][:confirm]
    if @person.save
      #prevent a user from using the reset link more than once
      @person.reset_password_link = nil
      @person.save
      redirect_to(login_path, :notice => "Your password has been reset.") and return
    else
      @person.reset_password_at = DateTime.current
      redirect_to(reset_password_confirm_path(:temp => @person.reset_password_link), :notice => "Could not reset password.  Please try again.")
    end
  end

private

  def valid_reset_password_link?(link)
    return Person.find_by_reset_password_link(link)
  end

  def reset_password_expired?(time)
    expiration_date = time.advance(:minutes => 10)
    return DateTime.current > expiration_date
  end
end
