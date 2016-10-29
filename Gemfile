source 'http://rubygems.org'
ruby '2.1.2'

gem 'activesupport'
gem 'activerecord-session_store'
gem 'authlogic'
gem 'd3js-rails', '~> 3.1.6'
gem 'exception_notification', '~> 4'
gem 'haml-rails'
gem 'jquery-rails', '~> 2.1.4'
gem 'mechanize'
gem 'net-ldap', :require => 'net/http'
gem 'nokogiri'
gem 'pg'
gem 'rails', '4.1.9'
gem 'rails-observers'
gem 'rdiscount'
gem 'recaptcha', :require => ['recaptcha', File.join('recaptcha', 'rails')]
gem 'ri_cal'
gem 'scrypt'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'will_paginate', '~> 3.0'
gem 'yaml_db'
gem 'materialize-sass'
gem 'rubycas-client', :git => 'git://github.com/rubycas/rubycas-client.git'

group :development do
  gem 'rails-erd' # Generate entity relationship diagram
end

group :development, :test do
  gem 'autotest-standalone'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers'
  gem 'simplecov', '~> 0.7.1', require: false

  # webrat is needed to make some specs pass
  gem 'webrat'
  gem 'yard'
end
