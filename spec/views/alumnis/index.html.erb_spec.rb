require 'rails_helper'

describe "alumnis/index.html.erb" do
  before(:each) do
    @alumnis = assign(:alumnis, [
      stub_model(Alumni,
        grad_semester: "Grad Semester",
        grad_school: "Grad School",
        job_title: "Job Title",
        company: "Company",
        salary: 1,
        person: nil
      ),
      stub_model(Alumni,
        grad_semester: "Grad Semester",
        grad_school: "Grad School",
        job_title: "Job Title",
        company: "Company",
        salary: 1,
        person: nil
      )
    ])
  end

  it "renders a list of alumnis" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: "Grad Semester".to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: "Grad School".to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: "Job Title".to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: "Company".to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: 1.to_s, count: 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: nil.to_s, count: 6
  end
end
