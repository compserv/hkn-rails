# - sudo su www-data and cd into hkn-rails
# - Run with rake coursesurveys:scrape["<url>","<full course names to permit>"]
#   The permit option is for courses which need to be specifically included
#   due to not having a lecture (such as 61AS).  Should be of the format
#   "COMPUTER SCIENCE 61AS, COMPUTER SCIENCE 375". Leave as "" if none
# - For url, do a search on schedule.berkeley.edu (e.g. for EE or CS department)
#   and take that url. (Should be osoc.berkeley.edu/...)
# - Some instructors may not be auto-identified.  You can manually enter id
#   Find ids in rail console.  (In terminal, "rails c production" to open console.)
#   In console, "Instructor.where(last_name: "<name>").take"

namespace :coursesurveys do

  desc "Scrape a schedule.berkeley url into this semester's course surveys to be surveyed"
  task :scrape, :url, :permit do |t, args|
    unless url = args.url
      puts "Enter the schedule.berkeley url"
      url = $stdin.readline.strip
    end
    permit = args.permit
    puts "Importing from #{url}..."
    importer = CourseSurveys::ScheduleImporter.new(url, permit)
    importer.import!
  end
end
