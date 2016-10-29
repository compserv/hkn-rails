require 'rails_helper'

describe "alumnis/new.html.erb" do
  before(:each) do
    @alumni = assign(:alumni, stub_model(Alumni,
      :grad_semester => "MyString",
      :grad_school => "MyString",
      :job_title => "MyString",
      :company => "MyString",
      :salary => 1,
      :person => nil
    ).as_new_record)
    @current_user = assign(:current_user, stub_model(Person,
      :first_name => "Irrelevant",
      :last_name => "Name"
    ))
  end

  it "renders new alumni form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => alumnis_path, :method => "post" do
      assert_select "input#alumni_grad_school", :name => "alumni[grad_school]"
      assert_select "input#alumni_job_title", :name => "alumni[job_title]"
      assert_select "input#alumni_company", :name => "alumni[company]"
      assert_select "input#alumni_salary", :name => "alumni[salary]"
    end
  end
end
