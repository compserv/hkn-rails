#!/usr/bin/env ruby
#
# Imports a CSV dump of the GoodProfOrNot database.
# Tables should be stored in individual .txt files together in the same folder.
# Data imported from:
#    - instructors
#    - questions
#    - seasons
#    - departments
#    - courses
#    - klasses
#    - instructors_klasses
#    - answers
# For specifics on fields imported, mappings, types, etc. see the individual
# load_whatever methods.
#
# For the larger tables (klasses, instructors) we try to cache mappings in
# .cache files, so that if the process is interrupted later, we can avoid
# re-processing all that data. This means that if you DO want to re-process, or
# if your tables were messed up between import sessions, you should delete the
# .cache files (or use the no-cache switch temporarily).
#
#
# Usage: ruby import_course_surveys -h
#
#
# Notes:
# - Since answers is freaking huge, there's a Postgres-specific optimization run
#   every 1000 rows (ANALYZE). This is like getting a golden mushroom with a
#   turbo button, and gives almost a factor of 4 speed increase (5 hours =>
#   1.25 hours for me). If you find this hard to believe, comment out the
#   optimization and watch your database wither and die halfway through.
# - It might help to periodically clear your terminal if you have verbose output
#   turned on. Otherwise you end up storing like 150k rows of text, if you have
#   unlimited scrollback.
#
# - TODO: Maybe some logging.
# - TODO: Resume partial loading of tables.
#
#
# - jonathanko
#

require 'optparse'          # useful for DRY options


###########
# Helpers #
###########

class Array

    # Returns an array of hashes, with each line in the input file mapped to a
    # hash according to the specified fields.
    #
    # Options:
    #   remove_slashes: remove slashes like in \, that were added to avoid problems
    #                   with CSV'ing strings containing commas.
    #
    def self.from_csv(file=nil, fields=nil, options={})
        raise ArgumentError if file.nil? or fields.nil?
        options = {:remove_slashes => true}.update(options)
        
        IO.readlines(file).collect do |line|
            h = {}
            # Ruby < 1.9 doesn't support negative lookbehinds.. wtf.
            # I'd like to do:
            #   /(?<!\\)\,[\s]*/
            # i.e. split on commas that aren't escaped.
            #
            # What we do instead is scan for each field.
            # A field is a run of chars that aren't ',' by itself (can still have
            # \, to indicate that a comma is part of the field). Match this zero
            # or more times (can have empty fields denoted by field1,,field3).
            # Then consume the comma and spaces. For good measure, also don't
            # include line breaks in the field matcher.
            #
            # Zip field names (hash keys) with scanned values to get an array of
            # KV pairs.
            #
            #                      _____fields____     delims
            #                     /               \   /      \
            fields.zip(line.scan(/((?:\\,|[^,\r\n])*)(?:,\s*)?/)).each do |kv|
                kv[1].first.gsub!(/\\/, '') if options[:remove_slashes]
                h[kv[0]] = kv[1].first
            end
            h
        end
    end
end

class Integer
    def to_bool
        (self == 0 ? false : true)
    end
end

class CourseSurveyImporter
# Puts GoodPOrN in your databases.
#

# Former table fields, used to import CSV
@@answer_fields = [:id, :klassid, :questionid, :frequencies, :mean, :deviation, :median, :orderinsurvey, :instructorid]
@@instructor_fields = [:id, :firstname, :lastname, :departmentid, :role, :title, :divisionid, :phone, :fax, :email, :office, :url, :comment_url, :assistant, :interests, :current, :most_recent_class, :picture_url, :private]
@@question_fields = [:id, :text, :subject, :important, :inverted, :ratingmax, :short, :keyword]
@@klass_fields = [:id, :courseid, :seasonid, :year, :section, :url]
@@season_fields = [:id, :name, :fraction]
@@course_fields = [:id, :coursename, :coursenumber, :level, :departmentid, :description, :url, :units, :current, :prerequisites, :newsgroup]
@@department_fields = [:id, :name, :abbrev]
@@instructorship_fields = [:klassid, :instructorid]

# Hashes of former id => new object
# Yes, these lines don't actually do anything, but looks like you have to
# initialize things in initialize() to have any effect.
@instructors
  @roles
@questions
@klasses
@seasons
@courses
@departments
@answers

# dump path
@dpath = nil

@options = {}
attr_accessor :options

def initialize
    @instructors, @roles, @questions, @klasses, @seasons, @courses, @departments, @answers = {}, {}, {}, {}, {}, {}, {}, {}
    @options = {}
end

def analyze(table)
    ActiveRecord::Base.connection.execute("ANALYZE #{table.to_s};")
end

def load_and_analyze(table)
    tablemap = {:answers=>:survey_answers, :questions=>:survey_questions}
    analyzetable = tablemap.member?(table) ? tablemap[table] : table
    self.send(:analyze, analyzetable) unless self.send("load_#{table.to_s}".to_sym) == false
end

def import!(options)
    raise "ERROR: no dump path provided!" unless @dpath = options[:from]

    puts "Welcome to import_course_surveys. This will take at least an hour, so you should go watch a movie, take a walk, etc. and check back later.\n\n"

    start_time = Time.now

    begin
        load_and_analyze(:instructors)
        load_questions
        load_seasons
        load_departments
        load_and_analyze(:courses)
        load_and_analyze(:klasses)
        load_instructorships
        load_and_analyze(:answers)
    rescue Exception => e
        puts "*"*80,"Import process interrupted!\n  (because #{e.message})\n\n"
    end
    
    dt = Time.now-start_time
    puts "Processing time: #{dt.to_i/3600}h#{(dt.to_i%3600)/60}m#{dt.to_i%60}s"
    
    # Here's the plan:
    # Coursesurvey: Represents an administration of a course survey. Has nothing
    #               to do with the survey data.
    # SurveyQuestions: Actual questions like "How hot was this prof?"
    # SurveyAnswers: Represents aggregate response to one question of one
    #               Coursesurvey
    # Instructor: Referenced by SurveyAnswer
    # Klass: Also referenced by SurveyAnswer, represents a semester of a class
    # Course: Referenced by Klass
    # Season: Summer, Fall, or Spring.
end

def dumpfilename(tablename)
    File.join(File.expand_path(@dpath, File.dirname(__FILE__)), "#{tablename}.txt")
end

def load_cache_hash(filename)
    # Returns true if successful, false on IO errors
    # provide a block of |old_id, new_id| for operations

    raise "Provide a block of |old_id, new_id|." unless block_given?
    begin
        File.open(filename, "r") do |f|
            puts "Reading cache file #{filename}... "
            num_entries = f.readline.match(/entries ([0-9]+)/i)[1].to_i
            if num_entries.nil? then
                puts "Malformed cache file #{filename}, no data loaded.\n"
                return
            end

            f.readlines.each do |line|
                line.gsub!(/\r\n/,'')
                old_id, new_id = line.split(' ')
                yield old_id.to_i, new_id.to_i
                num_entries -= 1
            end
            
            raise "Incomplete cache file #{filename}, expected #{num_entries} more. Only some data was loaded.\n" unless num_entries == 0
        end
        puts "Done.\n\n"
        return true
    rescue
        puts "Couldn't load cache file #{filename}.\n"
        return false
    end
end

def write_cache_hash(filename, h)
    # Writes a hash of old_id => new object to file
    #
    # Format:
    #   entries [#]
    #   [old_id] [new_id]
    #   ...
    
    begin
        File.open(filename, "w") do |f|
            puts "Writing cache file #{filename}... "
            f.write("entries #{h.length}\n")
            h.each_pair do |old_id, new_i|
                f.write("#{old_id} #{new_i.id}\n")
            end # h.each_pair
            
        end # IO.open
        puts "Done.\n"
        return true
    rescue
        puts "WARNING: Couldn't save cache file #{filename}\n"
        return false
    end

end

def load_instructors
    # Load instructor data.
    # Updates or creates new instructors. Any existing data is not overwritten,
    # except the 'private' attribute is set equal to loaded value.
    #
    return false if @options[:skip].include?(:instructors)
    instructor_map_cache_file = "instructors.cache"
    role_map_cache_file       = "roles.cache"
    
    puts "Loading instructors.\n"
    
    # Cache mappings
    return if load_cache_hash(instructor_map_cache_file) do |old_id, new_id|
        @instructors[old_id] = Instructor.find(new_id)
    end
    
    puts "Rebuilding.\n"
    
    instructors = Array.from_csv(dumpfilename("instructor"), @@instructor_fields, {:remove_slashes=>true} )
    instructors.each do |i|
        # Convert to booleans.
        [:private, :current].each { |k| i[k]=i[k].to_i.to_bool }
        
        # Convert to ints
        [:id, :departmentid, :divisionid].each {|k| i[k]=i[k].to_i}

        # Link to our new representation
        new_i = Instructor.find_or_create_by_first_name_and_last_name(i[:firstname], i[:lastname])
        # Update some attribs from i => new_i
        # Note: the ||= makes it UPDATE only. If any existing info is there, the
        # existing info won't be overwritten.
        {:email => :email, :title => :title, :phone => :phone_number, :office => :office, :private => :private, :url => :home_page, :interests => :interests, :picture_url => :picture}.each_pair do |old_attrib, new_attrib|
            if old_attrib == :private then
                # Special case: private defaults to true, so ||= won't do anything.
                new_i[:private] = i[:private]
            else
                # For all other attributes, update nil values.
                new_i[new_attrib] ||= i[old_attrib] unless i[old_attrib].eql?("N")
            end
        end

        # Store role for this instructor; there used to be multiple entries for same person for different roles
        # Roles is a mapping from old id to role
        @roles[i[:id]] = (i[:role] =~ /Professor/i) ? :professor : :ta

        raise "ERROR: load_instructors: Failed to save instructor:\n\n\t#{new_i.inspect}\n\n" unless new_i.save
        
        puts "load_instructors: Created/updated #{new_i.first_name} #{new_i.last_name} (new id #{new_i.id}, role #{i[:role]}, ta #{@roles[i[:id]] == :ta})\n" if @options[:verbose]
        
        # Save reference to newly created object, mapped by old id
        @instructors[i[:id]] = new_i
    end # instructors.each
    
    # Write to cache map
    write_cache_hash(instructor_map_cache_file, @instructors)
    #write_cache_hash(role_map_cache_file, @roles)
    
    puts "Done loading instructors.\n\n"
end # load_instructors

def load_questions
    return false if @options[:skip].include?(:questions)
    puts "Loading questions.\n"
    questions = Array.from_csv(dumpfilename("question"), @@question_fields)
    questions.each do |q|
        new_q = SurveyQuestion.find_or_create_by_text(q[:text])

        # Map old keywords => new keywords
        keymap = {"tep" => :prof_eff, "teta" => :ta_eff, "ww" => :worthwhile}
        keymap.default = :none
        q[:keyword] = keymap[q[:keyword]]
        
        # Cast to integer
        q[:ratingmax] = q[:ratingmax].to_i
        
        # Cast to bool
        [:important, :inverted].each do |attrib|
            q[attrib] = q[attrib].to_i.to_bool
        end
        
        # Map old attribs => new attribs
        {:text=>:text, :important=>:important, :inverted=>:inverted, :ratingmax=>:max}.each_pair do |old_attrib, new_attrib|
            new_q[new_attrib] = q[old_attrib]
        end
        
        # Special case: have to use keyword= method; new_q[:keyword]= doesn't work
        new_q.keyword = q[:keyword]
        
        # Integerify
        q[:id] = q[:id].to_i
        
        unless new_q.save
            puts "ERROR: failed to save question\n\n\t#{new_q.inspect}\n\n"
            next
        end
        @questions[q[:id]] = new_q
        
        puts "Created/updated question #{new_q.text}" if @options[:verbose]
    end # questions.each
    puts "Done loading questions.\n\n"
end # load_questions

def load_courses
    return false if @options[:skip].include?(:courses)
    puts "Loading courses."
    
    courses = Array.from_csv(dumpfilename("course"), @@course_fields)
    courses.each do |c|
        # Integerize some attribs
        [:id, :departmentid, :units].each do |key|
            c[key] = c[key].to_i
        end
        
        (prefix, course_number, suffix) = c[:coursenumber].scan(/^([a-zA-Z]*)([0-9]*)([a-zA-Z]*)$/).first
        
        # lol
        new_c = Course.find_or_create_by_department_id_and_prefix_and_course_number_and_suffix(@departments[c[:departmentid]].id, prefix, course_number, suffix)

        # Special processing
	c[:units] = nil if c[:units] <= 0
	c[:prerequisites] = nil if c[:prerequisites].eql?('N')
	c[:description] = nil if c[:description].eql?('N')
        
        # Map attribs
        {:coursename => :name, :description => :description, :units => :units, :prerequisites => :prereqs}.each_pair do |old_attrib, new_attrib|
            new_c[new_attrib] = c[old_attrib]
        end
        
        # Special cases
        
        # Some imported courses don't have names b/c they're not offered anymore.
        # Courses have to have names to be saved, so we do a minor hack.
        new_c[:name] = "[ INVALID COURSE ]" if new_c[:name].blank?
        
        
        
        # TODO: is this right?
        #       EE20N:
        #       prefix = something that's not EE.. i haven't seen these before
        #       course_number = 20
        #       suffix = N
        # TODO: what is new attrib 'level'?
        
        unless new_c.save
            raise "Couldn't save course #{new_c.inspect} because #{new_c.errors}!"
        end
        
        puts "Loaded course #{new_c.course_abbr}\n" if @options[:verbose]
        
        @courses[c[:id]] = new_c        
    end # courses.each
    
    puts "Done loading courses.\n\n"
end

def load_seasons
    return false if @options[:skip].include?(:seasons)
    puts "Loading seasons."
    
    seasons = Array.from_csv(dumpfilename("season"), @@season_fields)
    seasons.each do |s|
        s[:id] = s[:id].to_i
        @seasons[s[:id]] = s
        puts "Loaded season #{s[:name]}." if @options[:verbose]
        
        # There's no new Season/Semester model (it's stored as a string in klass).
        
    end
    
    puts "Done loading seasons.\n\n"
end

def load_departments
    return false if @options[:skip].include?(:departments)
    puts "Loading departments."
    
    departments = Array.from_csv(dumpfilename("department"), @@department_fields)
    departments.each do |d|
        d[:id] = d[:id].to_i
        
        dept = Department.find_or_create_by_name(d[:name])
        dept.abbr = d[:abbrev]
        unless dept.save
            puts "ERROR: Failed to load department #{dept.inspect}\n"
        end
        
        @departments[d[:id]] = dept
        
        puts "Loaded department #{d[:name]} (#{d[:abbrev]})." if @options[:verbose]
    end # departments.each
    
    puts "Done loading departments.\n\n"
end

def load_klasses
    return false if @options[:skip].include?(:klasses)
    puts "Loading klasses."

    klasses_map_cache_file = "klasses.cache"

    # Cache mappings
    return if load_cache_hash(klasses_map_cache_file) do |old_id, new_id|
        @klasses[old_id] = Klass.find(new_id)
    end
    
    klasses = Array.from_csv(dumpfilename("klass"), @@klass_fields)
    klasses.each do |k|
        # Integerize
        [:id, :courseid, :seasonid, :section].each do |attrib|
            k[attrib] = k[attrib].to_i
        end

        # Semester is like "20103" = "#{year}{season.number}"
        # with season numbers as defined in klass.
        #
        #
        # Source: coursesurveys_controller.klass
        #
        #           semester = year+season_no
        #
        sem_id = -1
        Klass::SEMESTER_MAP.each_pair do |sid, sname|
            if @seasons[k[:seasonid]][:name].downcase.eql?(sname.downcase) then
                sem_id = sid
                break
            end
        end
        semester = "#{k[:year]}#{sem_id}"

        new_k = Klass.find_or_create_by_course_id_and_semester_and_section(@courses[k[:courseid]].id, semester, k[:section])

        # Map attribs
        {:section => :section}.each_pair do |old_attrib, new_attrib|
            new_k[new_attrib] = k[old_attrib]
        end

        # Special processing
        new_k[:notes] = "Url: #{k[:url]}" unless k[:url].eql?("N")

        raise "ERROR: couldn't save klass #{new_k.inspect}" unless new_k.save(:validate => false)

        # TODO: time? location? num_students? This info isn't available for import.
        
        puts "Loaded klass #{new_k.course.course_abbr} #{@seasons[k[:seasonid]][:name]} #{k[:year]}\n" if @options[:verbose]

        @klasses[k[:id]] = new_k
    end # klasses.each
    
    # Write to cache map
    write_cache_hash(klasses_map_cache_file, @klasses)
    
    puts "Done loading klasses.\n\n"
end

def load_instructorships
    return false if @options[:skip].include?(:instructors_klasses)

    puts "Loading instructor-klass relationships."
    
    instructorships = Array.from_csv(dumpfilename("instructor_klass"), @@instructorship_fields)

    iship_sqls = []
    
    instructorships.each_index do |index|      
        i = instructorships[index]
        i[:klassid] = @klasses[i[:klassid].to_i].id
        i[:instructorid] = @instructors[i[:instructorid].to_i].id
        
        raise "Couldn't find klass #{i[:klassid]}!" if (the_klass=Klass.find(i[:klassid])).nil?
        raise "Couldn't find instructor #{i[:instructorid]}!" if (the_instructor=Instructor.find(i[:instructorid])).nil?
        
#        group = the_instructor.ta? ? :tas : :instructors
#        groupids = group.to_s.chop.concat('_ids').to_sym
        
        ta = "asdf"
        if existing = Instructorship.find(:first, :conditions => {:klass_id => the_klass.id, :instructor_id => the_instructor.id})
            ta = existing.ta
        else
            ta = (@roles[i[:instructorid]] == :ta)
            iship_sqls << [the_klass.id, the_instructor.id, ta]
#            unless iship = Instructorship.create(:klass_id => the_klass.id, :instructor_id => the_instructor.id, :ta => ta)
#              raise "ERROR saving instructorship #{iship.inspect}"
#            end
        end
#        unless the_klass.send(groupids).include?(i[:instructorid])
#            the_klass.send(group) << the_instructor
#            raise "ERROR saving #{group.to_s.chop} #{the_instructor.full_name} for klass #{the_klass.to_s}" unless the_klass.save
#        end
        
        puts "Created/updated instructorship #{index}/#{instructorships.length} of #{the_instructor.full_name} (#{ta.to_s}) for #{the_klass.to_s}" if @options[:verbose]
    end

    iship_sqls.each do |klass_id, instructor_id, ta|
        ta = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(ta)
        ActiveRecord::Base.connection.execute("INSERT INTO instructorships (klass_id, instructor_id, ta) VALUES (#{[klass_id, instructor_id, ta].join(', ')});")
    end
    
    puts "Done loading instructor-klass.\n\n"
end

def load_answers
    return false if @options[:skip].include?(:answers)

    puts "Loading answers."

    answers_map_cache_file = "answers.cache"
    
    analyze_counter = 0

    # Cache mappings
#    return if load_cache_hash(answers_map_cache_file) do |old_id, new_id|
#        @answers[old_id] = SurveyAnswer.find(new_id)
#    end

    a_sqls = []

    answers = Array.from_csv(dumpfilename("answer"), @@answer_fields)
    answers.each_index do |index|
        a = answers[index]
        
        # Integerize
        [:id, :klassid, :questionid, :orderinsurvey, :instructorid].each do |attrib|
            a[attrib] = a[attrib].to_i
        end
        
        # Floatize
        [:mean, :median, :deviation].each do |attrib|
            a[attrib] = a[attrib].to_f
        end
        
        
        # Find existing answer, or do weird stuff to create a new one
        new_klass_id, new_instructor_id, new_question_id = @klasses[a[:klassid]].id, @instructors[a[:instructorid]].id, @questions[a[:questionid]].id
###        new_a = SurveyAnswer.find_by_klass_id_and_instructor_id_and_survey_question_id(new_klass_id, new_instructor_id, new_question_id) || SurveyAnswer.new(:klass_id=>new_klass_id, :instructor_id=>new_instructor_id, :survey_question_id=>new_question_id)
##        conditions = {:klass_id=>new_klass_id, :instructor_id=>new_instructor_id, :survey_question_id=>new_question_id}
##        new_a = SurveyAnswer.find(:first, :conditions => conditions) || SurveyAnswer.send(:new, conditions)

        iship = Instructorship.where(:instructor_id => new_instructor_id, :klass_id => new_klass_id).limit(1).first
        raise "No existing instructorship for instructor #{new_instructor_id}, klass #{new_klass_id}" unless iship

        sa = SurveyAnswer.find(:first, :conditions => {:instructorship_id => iship.id, :survey_question_id => new_question_id})
        next if sa

##        # Map attribs
##        {:mean => :mean, :deviation => :deviation, :median => :median, :orderinsurvey => :order, :frequencies => :frequencies}.each_pair do |old_attrib, new_attrib|
##            new_a[new_attrib] = a[old_attrib]
##        end
        
        #raise "Couldn't save answer #{new_a.inspect} because #{new_a.errors}!" unless new_a.save(:validate=>false)
        
        a_sqls << [iship.id, new_question_id, a[:mean], a[:deviation], a[:median], a[:orderinsurvey], a[:frequencies]]

        # Hack to increase performance
        analyze_counter += 1
        ActiveRecord::Base.connection.execute("ANALYZE survey_answers;") if analyze_counter%1000 == 0

#        @answers[a[:id]] = new_a
        #puts "Created/updated answer (#{index}/#{answers.length}) ##{new_a.order} for #{new_a.instructor.full_name} for #{new_a.klass.to_s}" if @options[:verbose]
        puts "Created/updated answer (#{index}/#{answers.length}) ##{a[:orderinsurvey]} for #{iship.instructor_id} klass #{iship.klass_id}" if @options[:verbose]
    end # answers.each

    ActiveRecord::Base.connection.execute(
        a_sqls.collect do |a| #|iship_id, q_id, mean, dev, median, order, freq|
            "INSERT INTO survey_answers (instructorship_id, survey_question_id, mean, deviation, median, order, frequencies) VALUES (#{a.join(', ')});"
        end .join)
    
    # Write to cache map
#    write_cache_hash(answers_map_cache_file, @answers)

    puts "Done loading answers.\n\n"    
end

end # class CourseSurveyImporter





# int main(argc, char **argv) {
@csi = CourseSurveyImporter.new #(ARGV.first)
only = []

parser = OptionParser.new do |opts|
    opts.banner = "Usage: import_course_surveys [options] /path/to/dumpfolder"
    {:verbose => false, :clear => false, :skip => []}.each_pair do |option, value|
        @csi.options[option] = value
    end
    
    opts.on('-v', '--verbose', 'Output more detailed information (warning: spammy)') do
        @csi.options[:verbose] = true
    end
    opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit 0
    end
    opts.on('-o', '--only TABLE', 'Process only this/these table(s). You can specify multiple tables with multiple -o switches.') do |table|
      only << table.to_sym
    end
    opts.on('-s', '--skip TABLE', 'Skip table <instructors|courses|klasses|questions|answers|instructors_klasses|seasons|departments>') do |table|
        @csi.options[:skip] << table.to_sym
    end
end
parser.parse!

unless only.empty?
  @csi.options[:skip].concat( [:instructors, :courses, :klasses, :questions, :answers, :instructors_klasses, :seasons, :departments].reject {|t| only.include?(t)} )
end

if ARGV.empty?
    puts parser.help
    exit -1
else
    puts "Warming up... please wait."

    require 'rubygems'          # needed for activesupport
    require 'active_support'    # needed for json
    require File.expand_path('../../../../config/environment', __FILE__) # needed for hkn-rails classes
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)   # fake out sunspot

    puts "\n\n"
    ActiveRecord::Base.transaction do
        @csi.import!(:from => ARGV.first)
    end
end
puts "\nAll done.\n"
# }
