# Note: This is not an official raketask, I wrote it for our setup
# -richardxia

namespace :simple_cov do
  
  desc "Generates code coverage report."
  task :report do
    ENV['COVERAGE'] = "true"
    Rake::Task['spec'].invoke
  end
  
end
