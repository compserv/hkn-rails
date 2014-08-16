require 'spec_helper'

describe "alumnis/edit.html.erb" do
  before(:each) do
    @alumni = assign(:alumni, stub_model(Alumni,
      :grad_semester => "MyString",
      :grad_school => "MyString",
      :job_title => "MyString",
      :company => "MyString",
      :salary => 1,
      :person => nil
    ))
    @current_user = assign(:current_user, stub_model(Person,
      :first_name => "Irrelevant",
      :last_name => "Name"
    ))
  end

  it "renders the edit alumni form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => alumni_path(@alumni), :method => "post" do
      assert_select "input#alumni_grad_school", :name => "alumni[grad_school]"
      assert_select "input#alumni_job_title", :name => "alumni[job_title]"
      assert_select "input#alumni_company", :name => "alumni[company]"
      assert_select "input#alumni_salary", :name => "alumni[salary]"
    end
  end
end
