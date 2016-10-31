require 'rails_helper'

describe "dept_tour_requests/edit.html.erb" do
  before(:each) do
    @dept_tour_request = assign(:dept_tour_request, stub_model(DeptTourRequest))
  end

  it "renders the edit dept_tour_request form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: dept_tour_request_path(@dept_tour_request), method: "post" do
    end
  end
end
