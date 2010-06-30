require 'spec_helper'

describe "properties/show.html.erb" do
  before(:each) do
    assign(:property, @property = stub_model(Property,
      :tutor_version => 1,
      :semester => 'fa10'
    ))
  end

  it "renders attributes in <p>" do
    pending("fix or remove")
    render
   rendered.should contain(1)
   rendered.should contain('fa10')
  end
end
