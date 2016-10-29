require 'rails_helper'

describe "event_types/index.html.erb" do
  before(:each) do
    assign(:event_types, [
      stub_model(EventType),
      stub_model(EventType)
    ])
  end

  it "renders a list of event_types" do
    render
  end
end
