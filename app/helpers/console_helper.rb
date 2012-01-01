module ConsoleHelper

    # The console is implemented with one-off commands (we don't want to
    # bloat the session with tons of state).
    #
    # Basic usage:
    #   cmd = Console::Command.new( current_controller, "cmd arg0 arg1" )
    #   cmd.run
    #
  class Console

    #
    # Generic console error class
    #
    class Error < RuntimeError
      attr_reader :message

      # @param [String, #read] message
      def initialize(message=nil)
        @message = message
      end
    end

    #
    # Indicates that the user should be prompted for authentication credentials
    #
    class NeedSudoError < Error
    end

    #
    # Generic command response
    #
    class Response

      attr_reader :message      # [String] Text to send to stdout
      attr_reader :js           # [String] Arbitrary javascript to run

      # @param [String] args
      #   message
      # @param [String String] args
      #   message and javascript
      # @param [Hash] args
      #   * :message
      #   * :js
      #   * :redirect specifies that the response should redirect to this url
      #
      def initialize(*args)
        if args.count == 1

          if args.first.is_a? Hash
            @message, @js = args.first[:message], args.first[:js]
            if args.first[:redirect]
              @js ||= ""
              @js += "; window.location.replace(\"#{args.first[:redirect]}\");"
            end

          elsif args.first.is_a? String
            @message = args.first
          end

        elsif args.count > 1

          @message, @js = args[0], args[1]

        end
      end
    end

    #
    # Contains state and logic necessary to run a single command
    #
    class Command

      module Security

        # After this length of time, 'sudo' will require
        # the user to log in again.
        SudoTimeout = 2.minutes

      end

      # Was this command run with superuser permissions?
      attr_reader :sudo

      # @param [ActionController] controller
      #   The calling controller. Needed to reference current_user and for su.
      # @param [String,Array<String>] args
      #   Command and its args (if any)
      def initialize(controller=nil, *args)
        raise "no controller" unless @controller = controller

        # If args is a single string or array of strings, parse
        # it properly.
        if args.count == 1
          args = args.first.split if args.first.is_a? String
          args = args.first if args.first.is_a? Array
        end

        @cmd, @args = args.first, args[1..-1]
        sudo = false

        # Retrieve (for convenience) current user info from controller
        @current_user, @real_current_user = @controller.current_user, @controller.real_current_user
      end

      #
      # Attempt to run this command.
      # Raises {Console::Error Console::Error} if this command is not recognized.
      #
      def run
        case @cmd
        when 'su'
          require_sudo
          m_su(@args.first)
        when 'logout', 'exit'
          m_logout
        when 'shutdown'
          m_shutdown
        when 'sl'
          m_sl
        when 'sudo'
          m_sudo(@args)
        when 'touch'
          m_touch(@args.first)
        else
          raise Console::Error.new("#{@cmd}: command not found")
        end
      end

    protected
      attr_writer :sudo

    private
      # Raise an error if this command has not been run with {#sudo sudo}
      def require_sudo
        raise Console::Error.new("y u no sudo") unless sudo
        sudo
      end

      # Require that the user has 'entered a sudo password' before running.
      # This is equivalent to having a fresh login session.
      # Permissions are for the {ApplicationController#real_current_user real
      # current user}, since the regular current user may be from su.
      #
      # @raise {Console::Error}
      #   if the user is not {Person#admin? admin?}.
      # @raise {Console::NeedSudoError}
      #   if the user is admin but needs to reauthenticate due to stale sudo
      #   session.
      #
      # @see Console::Security::SudoTimeout
      #
      def check_sudo_session
        unless @real_current_user.admin?
          raise Console::Error.new("#{@real_current_user.username} is not in the sudoers file. This incident will be reported.") unless @real_current_user.admin?
        end

        unless (@real_current_user.current_login_at > Security::SudoTimeout.ago rescue false)
          raise Console::NeedSudoError
        end
      end

      # Spawn and run another command with sudo permissions.
      # Does not run if {#check_sudo_session} fails.
      #
      # @param [String,Array<String>]
      #   args passed directly as args of spawned command
      #
      def m_sudo(args)
        check_sudo_session
        c = Command.new(@controller, args)
        c.sudo = true
        c.run
      end

      # Touches someone.
      #
      # @param [String] username
      #
      def m_touch(username)
        unless username and p = Person.find_by_username(username)
          raise Console::Error.new("touch: cannout touch `#{username}': Permission denied")
        end
        if username == 'amatsukawa'
          return Response.new("#{username} likes it")
        end
      end

      # Helper method for 'su' command.
      #
      # @param [String] username
      def m_su(username)
        if username.nil?
          raise Console::Error.new("You can't be root.")
        end

        # NOTE: ApplicationController.su is private, but we
        #       can still access it thanks to some Ruby magic.
        unless @controller.send(:su, username)
          raise Console::Error.new "No."
        end
        Response.new("Look down. Back up. Your user is now #{username}.",
                     "changeUser('#{@controller.real_current_user.username}', '#{username}');")
      end

      # Helper method for 'logout' command.
      # Undoes 'su' if real user is impersonating, or redirects to logout_path
      # if not impersonating.
      def m_logout
        impersonating = @controller.send(:impersonating?)
        @controller.send(:su, nil)
        if impersonating
          Response.new("You are now #{@controller.current_user.username}",
                       "changeUser('#{@controller.current_user.username}',undefined);")
        else
          Response.new(:redirect => @controller.send(:logout_path))
        end
      end

      # Helper method for joke 'shutdown' command.
      # Blacks out the page.
      def m_shutdown
        Response.new :js => "$(document.body).html('').css('background','black');.css('background-size', '100% 100%');"
      end

      # Helper method for joke 'sl' command.
      def m_sl
        Response.new :message => "YOU MEANT LS",
           :js => "puts(\"<iframe src='http://www.youtube.com/embed/ogxtd4ZmYac?autoplay=1&rel=0#t=3s' width='400' height='300'></iframe>\");"
      end

    end # Command

  end # Console

end
