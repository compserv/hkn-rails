class Admin < ApplicationController
  before_filter :authorize_officers
end