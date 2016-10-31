require 'rails_helper'

describe "alumnis/show.html.erb" do
  before(:each) do
    @alumni = assign(:alumni, stub_model(Alumni,
      grad_semester: "Grad Semester",
      grad_school: "Grad School",
      job_title: "Job Title",
      company: "Company",
      salary: 1,
      person: stub_model(Person, first_name: "FARTY", last_name: "MCFARTERSON")
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Grad Semester/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Grad School/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Job Title/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Company/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
