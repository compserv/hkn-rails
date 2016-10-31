require 'rails_helper'

describe "rsvps/edit.html.erb" do
  before(:each) do
    @event = stub_model(Event)
    @rsvp = stub_model(Rsvp,
      :new_record? => false,
      event: @event
    )
    assign(:event, @event)
    assign(:rsvp, @rsvp)
    assign(:current_user, stub_model(Person, fullname: "John Doe"))
  end

  it "renders the edit rsvp form" do
    render

    expect(rendered).to have_tag('form', with: { action: event_rsvp_path(@event, @rsvp), method: 'post' })
  end
end
