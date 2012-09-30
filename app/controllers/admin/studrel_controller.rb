class Admin::StudrelController < Admin::AdminController
  before_filter :authorize_studrel

  def index
  end
end
