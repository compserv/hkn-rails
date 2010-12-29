class Admin::DeprelController < Admin::AdminController
  before_filter :authorize_deprel
  
  def overview
    @dept_tour_requests = DeptTourRequest.all
    render 'dept_tour_requests/index'
  end
end