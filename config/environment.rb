# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HknRails::Application.initialize!

LDAP_SERVER = 'hkn.eecs.berkeley.edu'
LDAP_SERVER_PORT = 389
