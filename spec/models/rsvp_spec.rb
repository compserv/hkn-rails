require 'spec_helper'

describe Rsvp, "when created with blank parameters" do
  before(:each) do
    @rsvp = Rsvp.create
  end

  it "should require a person and event to be valid" do
    @rsvp.should_not be_valid
    @rsvp.errors[:person].should include("can't be blank")
    @rsvp.errors[:event].should include("can't be blank")
  end
end

describe Rsvp do
  before(:each) do
    @good_opts = { :event => mock_model(Event),
      :person => mock_model(Person) }
  end

  it "should be valid when supplied a person and event" do
    rsvp = Rsvp.create(@good_opts)
    rsvp.should be_valid
  end
end