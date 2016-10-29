require 'spec_helper'

describe "event_types/edit.html.erb" do
  before(:each) do
    @event_type = assign(:event_type, stub_model(EventType,
      :new_record? => false
    ))
  end

  it "renders the edit event_type form" do
    render

    expect(rendered).to have_tag('form', with: { action: event_type_path(@event_type), method: "post" })
  end
end
