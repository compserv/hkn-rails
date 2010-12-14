require 'spec_helper'

describe "event_types/show.html.erb" do
  before(:each) do
    @event_type = assign(:event_type, stub_model(EventType))
  end

  it "renders attributes in <p>" do
    render
  end
end
