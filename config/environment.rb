RAILS_GEM_VERSION = '3.0'
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HknRails::Application.initialize!

LDAP_SERVER = 'hkn.eecs.berkeley.edu'
LDAP_SERVER_PORT = 389

require 'casclient'
require 'casclient/frameworks/rails/filter'
CASClient::Frameworks::Rails::Filter.configure(
  cas_base_url: "https://auth.berkeley.edu/cas/"
)
