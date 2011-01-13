class Admin::IndrelController < Admin::AdminController
  before_filter :authorize_indrel

  def indrel_db
  end
end
