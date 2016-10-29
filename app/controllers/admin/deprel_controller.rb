class Admin::DeprelController < Admin::AdminController
  before_filter :authorize_deprel

  def overview
    redirect_to dept_tour_requests_path
  end
end