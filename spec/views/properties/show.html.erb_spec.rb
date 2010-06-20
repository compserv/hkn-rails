require 'spec_helper'

describe "properties/show.html.erb" do
  before(:each) do
    assign(:property, @property = stub_model(Property,
      :tutor_version => 1,
      :semester => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
   rendered.should contain(1)
   rendered.should contain("MyString")
  end
end
