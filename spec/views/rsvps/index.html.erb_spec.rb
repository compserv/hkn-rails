require 'rails_helper'

describe "rsvps/index.html.erb" do
  before(:each) do
    @event = stub_model(Event)
    @person = stub_model(Person, fullname: "John Doe")

    assign(:event, @event)
    assign(:rsvps, [
      stub_model(Rsvp, event: @event, person: @person),
      stub_model(Rsvp, event: @event, person: @person)
    ])
    assign(:auth, {})
  end

  it "renders a list of rsvps" do
    render
  end
end
