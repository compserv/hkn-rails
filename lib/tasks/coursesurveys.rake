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
