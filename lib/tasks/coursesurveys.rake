namespace :coursesurveys do

  desc "Scrape a schedule.berkeley url into this semester's course surveys to be surveyed"
  task :scrape, :url do |t, args|
    unless url = args.url
      puts "Enter the schedule.berkeley url"
      url = $stdin.readline.strip
    end
    puts "Importing from #{url}..."
    importer = CourseSurveys::ScheduleImporter.new(url)
    importer.import!
  end
end
