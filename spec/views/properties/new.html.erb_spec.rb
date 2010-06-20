require 'spec_helper'

describe "properties/new.html.erb" do
  before(:each) do
    assign(:property, stub_model(Property,
      :new_record? => true,
      :tutor_version => 1,
      :semester => "MyString"
    ))
  end

  it "renders new property form" do
    render

    rendered.should have_selector("form", :action => properties_path, :method => "post") do |form|
      form.should have_selector("input#property_tutor_version", :name => "property[tutor_version]")
      form.should have_selector("input#property_semester", :name => "property[semester]")
    end
  end
end
