require 'spec_helper'

describe "properties/edit.html.erb" do
  before(:each) do
    assign(:property, @property = stub_model(Property,
      :new_record? => false,
      :tutor_version => 1,
      :semester => "MyString"
    ))
  end

  it "renders the edit property form" do
    render

    rendered.should have_selector("form", :action => property_path(@property), :method => "post") do |form|
      form.should have_selector("input#property_tutor_version", :name => "property[tutor_version]")
      form.should have_selector("input#property_semester", :name => "property[semester]")
    end
  end
end
