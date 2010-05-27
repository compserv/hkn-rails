require 'spec_helper'

describe Event, "when created with blank parameters" do
  before(:each) do
    @event = Event.create
  end

  it "should require a name to be valid" do
    @event.should_not be_valid
    @event.errors[:name].should include("can't be blank")
  end
end

describe Event do
  before(:each) do
    @good_opts = {:name => "Fun Event", 
      :start_time => DateTime.parse("2010-05-26 18:00:00 UTC"),
      :end_time => DateTime.parse("2010-05-26 20:00:00 UTC")}
    @bad_opts = {:name => "Fun Event", 
      :start_time => DateTime.parse("2010-05-26 18:00:00 UTC"),
      :end_time => DateTime.parse("2010-05-26 16:00:00 UTC")}
  end

  it "should accept valid parameters" do
    event = Event.create(@good_opts)
    event.should be_valid
  end

  it "should require the start time to be earlier than the end time" do
    event = Event.create(@bad_opts)
    event.should_not be_valid
    event.errors[:base].should include("Start time must be less than end time")
  end
end
