source 'https://rubygems.org'
ruby '2.5.7'

# Pin Rails to a strict version, since can easily have breaking changes
gem 'rails', '4.2.11.1'

# Authentication without having to write it all from scratch
gem 'authlogic', '~> 3.6'

# D3.js charts for course guide and course survey pages
gem 'd3js-rails', '~> 3.1.6'

# Send exception emails if anything breaks
gem 'exception_notification', '~> 4'

# Use HAML for some templates
gem 'haml-rails', '~> 1.0'

# Use jQuery for nicer JS and more browser compatability
gem 'jquery-rails', '~> 4.3.1'

# Rails observers were removed from Rails core in 4.0, these are used for model
# life-cycle callbacks (after_save, before_create, etc.)
gem 'rails-observers', '~> 0.1.5'

# Markdown parser, used for static page contents
gem 'rdiscount', '~> 2.2.0'

# Used for captchas on department tour request pages, etc.
gem 'recaptcha', '~> 4.6', require: ['recaptcha', 'recaptcha/rails']

# Support class-level responders in Rails 4.2+
gem 'responders', '~> 2.4'

# iCalendar support on the events pages
gem 'ri_cal', '~> 0.8'

# Sass support for stylesheets
gem 'sassc-rails', '~> 2.1'

# More secure password hashing for authentication
gem 'scrypt', '~> 3.0'

# Indrel company payments by credit card
gem 'stripe', '~> 3.9'

# Full-text searching using Solr for exams and course surveys
gem 'sunspot_rails', '~> 2.2'
gem 'sunspot_solr', '~> 2.2'

# Pagination on long pages
gem 'will_paginate', '~> 3.1'

# TODO: Replace this gem with one that is maintained, like
# rack-cas or omniauth-cas
# This is used for course surveys so that professors and TAs/GSIs can log in
# and see their survey results using their Berkeley login
gem 'rubycas-client', git: 'https://github.com/rubycas/rubycas-client'

# The OCF hosting includes MySQL, so we use that
gem 'mysql2', '~> 0.4.0'

# Production-only gems
group :production do
  # Rollbar is nice for reporting errors in production instead of (or
  # alongside) spamming emails. It also records deploys, which is nice
  gem 'rollbar', '~> 2.22'

  # JS compression and minification for production
  gem 'uglifier', '~> 4.1'

  # Unicorn is a nice application server that has multiple workers, making the
  # site scale a bit better if under load
  gem 'unicorn', '~> 5.4'

  # Kill unicorn workers after a certain number of requests or if they use too
  # much memory to prevent them getting too bloated
  gem 'unicorn-worker-killer', '~> 0.4'
end

# Development-only gems
group :development do
  # Generate entity relationship diagrams between models
  gem 'rails-erd', '~> 1.5'

  # Use a different development server (generally a bit faster and lightweight)
  gem 'thin', '~> 1.7'

  # Annotate models with database information
  gem 'annotate', '~> 2.7'

  # Nicer error pages with an interactive console
  gem 'better_errors', '~> 2.4'
  gem 'binding_of_caller', '~> 0.8'

  # Deploy to production with capistrano. Needed in development because that's
  # where the deploys occur from
  gem 'capistrano',               '~> 3.10.2', require: false
  gem 'capistrano-bundler',       '~> 1.3',    require: false
  gem 'capistrano-faster-assets', '~> 1.1',    require: false
  gem 'capistrano-rails',         '~> 1.3',    require: false
  gem 'capistrano-rvm',           '~> 0.1',    require: false
end


# Development and testing gems
group :development, :test do
  # General testing gems for rspec
  gem 'autotest-rails',            '~> 4.2'
  gem 'rspec-rails',               '~> 3.7'
  gem 'rspec-activemodel-mocks',   '~> 1.0'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'rspec-html-matchers',       '~> 0.9'

  # Check how much code is covered by tests
  gem 'simplecov', '~> 0.7.1', require: false

  # Webrat for some acceptance tests
  gem 'webrat', '~> 0.7'

  # Documentation generation
  gem 'yard',   '~> 0.9.20'
end

# Block certain IPs that spam
# https://blog.kommit.co/how-to-protect-your-rails-app-from-bad-clients-a6eda756e1c4
gem 'rack-attack', '~> 6.2', '>= 6.2.2' 
gem 'figaro'
