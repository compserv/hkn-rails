require 'spec_helper'

describe "event_types/new.html.erb" do
  before(:each) do
    @event_type = stub_model(EventType, :new_record? => true)
    assign(:event_type, @event_type)
  end

  it "renders new event_type form" do
    render

    expect(rendered).to have_tag('form', with: { action: event_type_path(@event_type), method: 'post' })
  end
end
