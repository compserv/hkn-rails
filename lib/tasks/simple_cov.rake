# Note: This is not an official raketask, I wrote it for our setup
# -richardxia

namespace :simple_cov do
  
  desc "Generates code coverage report."
  task :report do
    require 'simplecov'
    SimpleCov.start 'rails' do
      add_filter '.bundle'
      add_filter 'vendor'
    end
    puts "Running SimpleCov"
    Rake::Task['spec'].invoke
  end
  
end
