require 'spec_helper'

describe "dept_tour_requests/show.html.erb" do
  before(:each) do
    @dept_tour_request = assign(:dept_tour_request, stub_model(DeptTourRequest))
  end

  it "renders attributes in <p>" do
    render
  end
end
