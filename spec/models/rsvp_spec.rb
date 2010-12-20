require 'spec_helper'

describe Rsvp, "when created with blank parameters" do
  before(:each) do
    @rsvp = Rsvp.create
  end

  it "should require a person to be valid" do
    @rsvp.should_not be_valid
    @rsvp.errors[:person].should include("can't be blank")
  end

  it "should require an event to be valid" do
    @rsvp.should_not be_valid
    @rsvp.errors[:event].should include("can't be blank")
  end

  it "should require a block to be valid" do
    @rsvp.should_not be_valid
    @rsvp.errors[:blocks].should include("must include at least one block")
  end
end

describe Rsvp do
  before(:each) do
    block = mock_model(Block)
    # Hack to make many to many associations work. Rspec has a bug here
    block.stub(:record_timestamps, false)
    @good_opts = { :event => mock_model(Event),
      :person => mock_model(Person), :blocks => [block]}
  end

  it "should be valid when supplied a person, event, and block" do
    rsvp = Rsvp.create(@good_opts)
    rsvp.should be_valid
  end
end
