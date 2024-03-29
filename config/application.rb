require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'will_paginate/array'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module HknRails
  class Application < Rails::Application
    require 'django_sha1'
    require 'acts_as_notification'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W(lib/validators)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    # config.active_record.observers = :election_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, fixture: true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Exception Notification
    config.middleware.use ExceptionNotification::Rack,
      ignore_exceptions: [
        'ActionController::BadRequest',
        'ActionController::UnknownFormat'
      ] + ExceptionNotifier.ignored_exceptions,
      ignore_crawlers: %s{PiplBot SemrushBot},
      error_grouping: true,
      email: {
        email_prefix: '[hkn-rails Exception] ',
        sender_address: '"hkn-rails Notifier" <notifier@hkn.eecs.berkeley.edu>',
        exception_recipients: ['website-errors@hkn.eecs.berkeley.edu']
      }

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.middleware.use Rack::Attack
  end
end
