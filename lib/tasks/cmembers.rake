namespace :users do

  namespace :assign do

  desc "Assign committee members"
  task :cmembers do
    class CheckError < StandardError; end
    class FatalError < StandardError; end
    class Done       < StandardError; end

    Person.transaction do begin
      op_rename = lambda do
          old_username = UI::request "old username"
          new_username = UI::request "new username"

          raise(CheckError, "#{old_username} not found") if !Person.exists?(:username => old_username)
          raise(CheckError, "#{new_username} already take") if Person.exists?(:username => new_username)

          p = Person.find_by_username(old_username)
          unless p.update_attribute(:username, new_username)
            raise FatalError, p.errors.inspect
          end
      end # op_rename

      op_add = lambda do
        username = UI::request "username"
        comm = UI::request "committee"
        comms = Group.find_by_name('comms')

        unless p = Person.find_by_username(username)
          raise CheckError, "unknown user: #{username}"
        end

        unless g = Group.find_by_name(comm)
          raise CheckError, "unknown group: #{comm}"
        end

        if c = p.committeeships.current.first
          raise CheckError, "committeeship already exists: #{c.inspect}"
        end

        c = Committeeship.new(:committee => comm, :person => p, :semester => Property.current_semester, :title => 'cmember')
        unless c.save
          raise FatalError, "cship invalid: #{c.errors.inspect}"
        end

        p.groups |= [g, comms]
        unless p.save
          raise FatalError, "failed to update groups: #{p.errors.inspect}"
        end
      end # op_add

      loop do
        UI::menu [
          'Rename user',
          'Add user to committee',
          'Abort',
          'Save & Quit'
        ] do |choice|
          begin
            case choice
            when 1
              op_rename.call
              true
            when 2
              op_add.call
              true
            when 3
              raise FatalError, "User aborted"
            when 4
              raise Done
            else
              raise CheckError, "unknown option #{choice}"
            end
          rescue Done
            raise
          rescue FatalError => e
            puts "\n***FATAL: #{e.message}"
            puts "\nAll changes from this session will be reverted.\n"
            raise
          rescue => e
            puts "\n***Error: #{e.message}"
          end
        end # UI::menu
      end # UI::menu loop

    rescue Done
      puts "Committing..."
    rescue => e
      raise
    end
    end # Person.transaction

  end # users:assign:cmembers

  end # users:assign

end # users
