HknRails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  #config.action_controller.perform_caching = true
  #config.action_controller.page_cache_directory = File.join Rails.root, 'public', 'cache'

  # TODO: Enable force_ssl once moved to the OCF
  config.force_ssl = false
  unless defined? Rails::Configuration::SSL
    module Rails module Configuration
      SSL = ! File.file?(".nossl")
    end end
  end

  # Compress JavaScripts and CSS.
  # The sass-rails gem is automatically used for CSS compression if included in Gemfile and
  # no config.assets.css_compressor option is set.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Specifies the header that your server uses for sending files
  # For nginx:
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  # For apache:
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = :file_store, File.join(Rails.root, 'tmp', 'cache')

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_files = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'hkn.eecs.berkeley.edu',
      user_name:            'hknwebsite@hkn.eecs.berkeley.edu',
      password:             Rails.application.secrets.mail_password,
      authentication:       'plain',
      enable_starttls_auto: true
  }

  # Enable threaded mode
  # config.threadsafe!

  config.active_support.deprecation = :notify

  config.eager_load = true

  config.log_level = :info

  # Turn off ip spoofing checks, since they are spammy and not helpful since we
  # don't do IP-based whitelisting
  config.action_dispatch.ip_spoofing_check = false
end
