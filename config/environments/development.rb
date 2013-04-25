HknRails::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Don't show SQL spam
  config.log_level = :info

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

  if ENV['CACHING'] =~ /true|1|on|yes/ then
    config.action_controller.perform_caching = true
    config.action_controller.page_cache_directory = File.join Rails.root, 'public', 'cache'
    config.cache_store = :file_store, File.join(Rails.root, 'tmp', 'cache')
    puts "Caching is ON"
  else
    config.action_controller.perform_caching = false
  end

  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = {
    location: File.join(Rails.root, 'tmp', 'mails')
  }
  config.action_mailer.raise_delivery_errors = true

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end
