require 'spec_helper'

describe Availability, "when created with blank parameters" do
  before(:each) do
    @availability = Availability.create
  end

  it "should require a tutor to be valid" do
    @availability.should_not be_valid
    @availability.errors[:tutor].should include("can't be blank")
  end

  it "should require a preference_level to be valid" do
    @availability.should_not be_valid
    @availability.errors[:preference_level].should include("can't be blank")
  end

  it "should require a hour to be valid" do
    @availability.should_not be_valid
    @availability.errors[:hour].should include("can't be blank")
  end

  it "should require a wday to be valid" do
    @availability.should_not be_valid
    @availability.errors[:wday].should include("can't be blank")
  end
end

describe Availability do
  before(:each) do
    @good_opts = { 
      :tutor_id => Tutor.create,
      :preference_level => 1,
      :preferred_room => 1,
      :hour => 11,
      :wday => 1,
    }
  end

  it "should accept valid parameters" do
    availability = Availability.create(@good_opts)
    availability.should be_valid
  end

  it "should require a valid room" do
    availability = Availability.create(@good_opts.merge(:preferred_room => 5))
    availability.should_not be_valid
    availability.errors[:preferred_room].should include(Availability::ROOM_ERROR)
  end
end
