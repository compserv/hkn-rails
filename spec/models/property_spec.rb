require 'spec_helper'

describe Property do
  before(:each) do
    Property.destroy_all
    @good_opts = {
	:tutor_version => 1,
	:semester => 'fa10'
	}
  end
  it "should accept valid parameters" do
	prop = Property.create(@good_opts)
	prop.should be_valid
  end
  it "should not allow multiple properties" do
	p1 = Property.create(@good_opts)
	p1.should be_valid
	p2 = Property.create(@good_opts)
	p2.should_not be_valid
	p2.errors[:base].should include("There can only be one property entry") 
  end
  it "should require a valid semester" do
    prop = Property.create(@good_opts.merge(:semester => 'fa100'))
	prop.should_not be_valid
	prop.errors[:semester].should include("Not a valid semester.")
  end
  it "should require a valid tutor version" do
    prop = Property.create(@good_opts.merge(:tutor_version => 'over 9000'))
	prop.should_not be_valid
  end
  it "should allow convenience getters and setters for tutor_version" do
    Property.tutor_version = 4
    Property.tutor_version.should == 4
  end
  it "should allow convenience getters and setters for semester" do
    Property.semester = 'sp10'
    Property.semester.should == 'sp10'
  end
end
