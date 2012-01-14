source 'http://rubygems.org'

#gem 'rails', "> 3.0", "< 3.1"
gem 'rails', "~> 3.1"

gem 'pg'

gem 'authlogic'
gem 'net-ldap', :require => 'net/http'
gem 'nokogiri'
gem 'will_paginate', "~> 3.0.pre2"
gem 'yaml_db'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'jquery-rails', '>= 0.2.6'

gem "exception_notification",
        :git => "git://github.com/rails/exception_notification.git",
        :require => "exception_notifier"

gem 'recaptcha', :require => ['recaptcha', File.join('recaptcha', 'rails')]

gem 'ri_cal'

group :development, :test do
  gem 'rspec-rails'
  # webrat is needed to make some specs pass
  gem 'webrat'
  gem 'ZenTest'
  gem 'autotest-rails'
  gem 'simplecov', :require => false
  gem 'yard'
end
