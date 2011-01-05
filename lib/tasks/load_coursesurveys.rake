namespace :coursesurveys do
  dumparchive = File.join('script', 'import_django', 'course_surveys', 'goodprofornot_dump.tar.bz2')

  desc "Loads course survey data from archive in #{dumparchive}"
  task :load_from_archive do
    raise "Error: Couldn't find #{dumparchive}" unless File.file?(dumparchive)
    puts "Extracting from archive #{dumparchive} to db/..."
    system "tar -C db -xf #{dumparchive}"
    # system "export dir=goodprofornot_dump"
    puts "Loading..."
    ENV['dir'] = 'goodprofornot_dump'
    Rake::Task['db:data:load_dir'].invoke
    puts "Done. I left db/goodprofornot_dump in your db folder, which you may want to remove."
  end
end
