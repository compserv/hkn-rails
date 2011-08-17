class Admin::PresController < Admin::AdminController
  before_filter :authorize_pres

  def index
  end
end
