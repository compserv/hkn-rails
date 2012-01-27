require 'spec_helper'

describe Rsvp do
  before(:each) do
    block = mock_model(Block)
    # Hack to make many to many associations work. Rspec has a bug here
    block.stub(:record_timestamps, false)
    @good_opts = { :event => mock_model(Event),
      :person => mock_model(Person), :blocks => [block]}
  end

  describe "when created with blank parameters" do
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

  describe "mass-assignment attributes" do
    before :each do
      @event = mock_model(Event)
      @person = mock_model(Person)
    end

    it "should not include event, person, confirmed" do
      Rsvp.new(:event => @event).event.should_not == @event
      Rsvp.new(:person => @person).person.should_not == @person
      Rsvp.new(:confirmed => Rsvp::Confirmed).confirmed.should_not == Rsvp::Confirmed
    end
  end

  describe "for non-transportation event" do
    before :each do
      @event = mock_model(Event, :need_transportation => false)
    end

    it "should be valid when supplied a person, event, and block" do
      rsvp = new_rsvp(:event => @event)
      rsvp.should be_valid
    end

    it "should also be valid with transportation specified" do
      rsvp = new_rsvp(:event => @event)
      rsvp.transportation = Rsvp::TRANSPORT_ENUM.first.last
      rsvp.should be_valid
    end
  end

  describe "for transportation event" do
    before :each do
      @event = mock_model(Event, :need_transportation => true)
    end

    it "should be valid with transportation field" do
      rsvp = new_rsvp(:event => @event, :transportation => Rsvp::TRANSPORT_ENUM.first.last)
      rsvp.errors_on(:transportation).should be_empty
    end

    describe "default transportation" do
      it "should be set when no value provided" do
        rsvp = new_rsvp(:event => @event, :transportation => nil)
        rsvp.errors_on(:transportation).should be_empty
        rsvp.transportation.should_not be_nil
      end

      it "should not be changed when a value is provided" do
        t = 4
        rsvp = new_rsvp(:event => @event, :transportation => t)
        rsvp.errors_on(:transportation).should be_empty
        rsvp.transportation.should_not == t
      end
    end
  end

  def new_rsvp(stubs={})
    r = Rsvp.new
    {
      :person => mock_model(Person),
      :blocks => [stub_model(Block)],
      :event  => mock_model(Event)
    }.each_pair do |k,v|
      r.send "#{k.to_s}=".intern, (stubs.include?(k) ? stubs[k] : v)
    end
    r
  end

end
