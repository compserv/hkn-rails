require 'spec_helper'

describe "properties/index.html.erb" do
  before(:each) do
    assign(:properties, [
      stub_model(Property,
        :tutor_version => 1,
        :semester => "MyString"
      ),
      stub_model(Property,
        :tutor_version => 1,
        :semester => "MyString"
      )
    ])
  end

  it "renders a list of properties" do
    render
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end
