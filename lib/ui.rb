module UI

    class << self

    # Print a description and retrieve a response from the input stream.
    # @param prompt [String] describes the desired input
    # @param options [Hash]
    #   * stream [Stream] : input stream, default $stdin
    # @return [String] stripped user input
    def request(prompt=nil, options={})
      $stdout.write "\n#{prompt || ''}\n> "
      options[:stream] ||= $stdin
      return options[:stream].readline.strip
    end

    # Present the user with a menu
    # @param title [String] [optional] Title to print
    # @param block [Block] Chosen option is yielded to the block
    #        Return true to terminate the menu.
    def menu(*args, &block)
      title = (args.first.is_a?(String) ? args.shift : nil)
      choices = args.first
      begin
        puts '',title
        choices.each_with_index {|c,i| puts "#{(i+1).to_s.rjust 3}) #{c}"}
      end until yield(request.to_i)
      puts
    end

    # Ask for confirmation (y/n)
    # @param prompt [String]
    # @param options [Hash]
    # @return [Boolean] yes => true, no => false
    def confirm(prompt=nil,options={})
      prompt = "#{prompt} [y/n]" if prompt
      !!(request(prompt) =~ /yes|y/i)
    end

    end

end
