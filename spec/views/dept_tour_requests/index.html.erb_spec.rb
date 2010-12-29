require 'spec_helper'

describe "dept_tour_requests/index.html.erb" do
  before(:each) do
    assign(:dept_tour_requests, [
      stub_model(DeptTourRequest),
      stub_model(DeptTourRequest)
    ])
    assign(:dept_tour_requests_unresponded, [
      stub_model(DeptTourRequest),
      stub_model(DeptTourRequest)
    ])
    assign(:dept_tour_requests_pending, [
      stub_model(DeptTourRequest),
      stub_model(DeptTourRequest)
    ])
  end

  it "renders a list of dept_tour_requests" do
    render
  end
end
