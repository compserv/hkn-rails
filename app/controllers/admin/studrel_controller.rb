class Admin::StudrelController < Admin::AdminController
  before_filter :authorize_tutoring

  def index
  end
end
