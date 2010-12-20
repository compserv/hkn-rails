require 'spec_helper'

describe "rsvps/show.html.erb" do
  before(:each) do
    # This should go into some global spec_helper file
    assign(:auth, {})

    person = stub_model(Person, :fullname => 'John Doe')
    event = stub_model(Event, :name => 'Tea Party')
    blocks = [
      stub_model(Block, :start_time => DateTime.new, :end_time => DateTime.new)
    ]
    rsvp = stub_model(Rsvp) do |r|
      r.person = person
      r.event = event
    end
    # Since blocks is a method and not a property of rsvp, you have to stub it
    rsvp.stub(:blocks) { blocks }

    assign(:rsvp, rsvp)
    assign(:event, event)
  end

  it "renders attributes in <p>" do
    render
  end
end
