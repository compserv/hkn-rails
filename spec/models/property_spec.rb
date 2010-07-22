require 'spec_helper'

describe Property do
  before(:each) do
    Property.destroy_all
    @good_opts = {
      :tutoring_enabled=>true,
      :semester => 'fa10'
	}
  end
  it "should require a valid semester" do
    prop = Property.get_or_create
    prop.semester = "fa100"
    prop.should_not be_valid
    prop.errors[:semester].should include("Not a valid semester.")
  end
  it "should allow convenience getters and setters for semester" do
    Property.semester = 'sp10'
    Property.semester.should == 'sp10'
  end
end
