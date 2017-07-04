source 'https://rubygems.org'
ruby '2.1.2'

gem 'activesupport'
gem 'activerecord-session_store'
gem 'authlogic'
gem 'd3js-rails', '~> 3.1.6'
gem 'exception_notification', '~> 4'
gem 'haml-rails'
gem 'jquery-rails', '~> 2.1.4'
gem 'mechanize'
gem 'net-ldap', '~> 0.16.0', require: 'net/http'
gem 'nokogiri'
gem 'pg'
gem 'rails', '4.2.9'
gem 'rails-observers'
gem 'rdiscount'
gem 'recaptcha', require: ['recaptcha', 'recaptcha/rails']
gem 'ri_cal'
gem 'scrypt'
gem 'stripe'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'will_paginate', '~> 3.0'
gem 'yaml_db'
gem 'sass-rails'

# Support class-level responders in Rails 4.2+
gem 'responders', '~> 2.0'

# TODO: Replace this gem with one that is maintained, like
# rack-cas or omniauth-cas
gem 'rubycas-client', git: 'https://github.com/rubycas/rubycas-client'

group :production do
  gem 'mysql2',  '~> 0.4'
  gem 'rollbar', '~> 2.14'
  gem 'unicorn', '~> 5.3'
end

group :development do
  # Generate entity relationship diagram
  gem 'rails-erd'

  # Use a different development server
  gem 'thin'

  # Annotate models with database information
  gem 'annotate'

  # Nicer error pages with an interactive console
  gem 'better_errors'
  gem 'binding_of_caller'

  # Deploy to production with capistrano
  gem 'capistrano',               '~> 3.8'
  gem 'capistrano-bundler',       '~> 1.2'
  gem 'capistrano-faster-assets', '~> 1.0'
  gem 'capistrano-rails',         '~> 1.3'
  gem 'capistrano-rvm',           '~> 0.1'
end

group :development, :test do
  gem 'autotest-rails'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers'
  gem 'simplecov', '~> 0.7.1', require: false

  # webrat is needed to make some specs pass
  gem 'webrat'
  gem 'yard'
end
