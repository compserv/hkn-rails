class Admin::AdminController < ApplicationController
  before_filter :authorize_officers
end
