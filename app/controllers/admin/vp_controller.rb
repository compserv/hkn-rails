include Process

class Admin::VpController < Admin::AdminController
  before_filter :authorize_vp

  def index
  end
end
