module ConsoleHelper

  class Console

    class Error < RuntimeError
      attr_reader :message

      def initialize(message)
        @message = message
      end
    end

    class Response
      attr_reader :message, :js

      ##
      # Args can be:
      #   (1)  message [String]
      #   (2)  message [String], js [String]
      #   (2)  { :message  => ...,
      #          :js       => ...,
      #          :redirect => ...
      #        }
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

    class Command
      def initialize(controller=nil, *args)
        raise "no controller" unless @controller = controller

        args = args.first.split if args.count == 1 and args.first.is_a? String
        puts args.inspect
        @cmd, @args = args.first, args[1..-1]
      end

      def run
        case @cmd
        when 'su'
          m_su(@args.first)
        when 'logout', 'exit'
          m_logout
        when 'shutdown'
          m_shutdown
        when 'sl'
          m_sl
        else
          raise Console::Error.new("#{@cmd}: command not found")
        end
      end

    private
      def m_su(username)
        # NOTE: ApplicationController.su is private, but we
        #       can still access it thanks to some Ruby magic.
        unless @controller.send(:su, username)
          raise Console::Error.new "No."
          return false
        end
        Response.new("Look up. Look down. Your user is now #{username}.",
                     "changeUser('#{@controller.real_current_user.username}', '#{username}');")
      end

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

      def m_shutdown
        Response.new :js => "$(document.body).html('').css('background','black');.css('background-size', '100% 100%');"
      end

      def m_sl
        Response.new :message => "YOU MEANT LS",
           :js => "puts(\"<iframe src='http://www.youtube.com/embed/ogxtd4ZmYac?autoplay=1&rel=0#t=3s' width='400' height='300'></iframe>\");"
      end

    end # Command

  end # Console

end
