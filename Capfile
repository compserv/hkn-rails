# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Use git as the SCM for capistrano
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#

# Use RVM to select which ruby to use
require 'capistrano/rvm'

# Reinstall bundle if any gems are added/removed/updated
require "capistrano/bundler"

# Precompile assets (SCSS, JS, images)
require "capistrano/rails/assets"

# Run database migrations if any are pending
require "capistrano/rails/migrations"

# Don't precompile assets if they haven't changed at all
require "capistrano/faster_assets"

# Add Rollbar deploy hook to notify Rollbar/Slack every deploy
require 'rollbar/capistrano3'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
