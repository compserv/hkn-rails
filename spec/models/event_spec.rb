# == Schema Information
#
# Table name: events
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  slug                     :string(255)
#  location                 :string(255)
#  description              :text
#  start_time               :datetime         not null
#  end_time                 :datetime         not null
#  created_at               :datetime
#  updated_at               :datetime
#  event_type_id            :integer
#  need_transportation      :boolean          default(FALSE)
#  view_permission_group_id :integer
#  rsvp_permission_group_id :integer
#  markdown                 :boolean          default(FALSE)
#

require 'rails_helper'

describe Event, "when created with blank parameters" do
  before(:each) do
    @event = Event.create
  end

  it "should require a name to be valid" do
    @event.should_not be_valid
    @event.errors[:name].should include("can't be blank")
  end
end

describe Event do
  before(:each) do
    @good_opts = {
      name: "Fun Event",
      start_time: DateTime.parse("2010-05-26 18:00:00 UTC"),
      end_time: DateTime.parse("2010-05-26 20:00:00 UTC"),
      location: "The Woz",
      description: "Very fun event",
      event_type: mock_model(EventType)
    }

    @bad_opts = {
      name: "Fun Event",
      start_time: DateTime.parse("2010-05-26 18:00:00 UTC"),
      end_time: DateTime.parse("2010-05-26 16:00:00 UTC")
    }
  end

  it "should accept valid parameters" do
    event = Event.create(@good_opts)
    event.should be_valid
  end

  it "should require a location" do
    event = Event.create(@bad_opts)
    event.should_not be_valid
    event.errors[:location].should include("can't be blank")
  end

  it "should require a description" do
    event = Event.create(@bad_opts)
    event.should_not be_valid
    event.errors[:description].should include("can't be blank")
  end

  it "should require the start time to be earlier than the end time" do
    event = Event.create(@bad_opts)
    event.should_not be_valid
    event.errors[:end_time].should include("must be after start time")
  end
end
