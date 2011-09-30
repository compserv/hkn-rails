class ConsoleController < ApplicationController
  include ConsoleHelper

  before_filter :authorize
  before_filter :keep_sudo_alive, :only => :command

  #
  # Open a new console
  #
  def open
  end

  #
  # Processes a user-typed command.
  #
  def command

    # messages holds text for stdout
    # js holds arbitrary javascript to execute
    @resp = { :messages => [], :js => [] }

    begin
      c = Console::Command.new(self, params[:command])
      if response = c.run
        # Success
        @resp[:messages] << response.message if response.message
        @resp[:js]       << response.js      if response.js
      end

    rescue Console::NeedSudoError
      @resp[:messages] << "[sudo] password for #{@real_current_user.username}: "
      @resp[:js]       << "reauthenticate();"

    rescue Console::Error
      @resp[:messages] << $!.message

    rescue # unexpected error
      @resp[:messages] << "< server error >"
      @resp[:messages] << $!.inspect if Rails.env == 'development'
      raise if Rails.env == 'development'

    end

    respond_to do |format|
      format.js
    end
  end

private
  # Keeps existing sudo session alive, if the current user is {Person#admin? admin?}.
  # Fakes out current_login_at to satisfy {Console::Command#check_sudo_session}
  # @return [true] (passive filter)
  def keep_sudo_alive
    if @real_current_user.admin? and @real_current_user.current_login_at > Console::Command::Security::SudoTimeout.ago
      @real_current_user.current_login_at = Time.now  # but don't save it!
    end
    true
  end

end
