# == Schema Information
#
# Table name: blocks
#
#  id         :integer          not null, primary key
#  rsvp_cap   :integer
#  start_time :datetime
#  end_time   :datetime
#  created_at :datetime
#  updated_at :datetime
#  event_id   :integer
#

require 'rails_helper'

describe Block, "when created with blank parameters" do
  before(:each) do
    @block = Block.create
  end

  it "should not be valid" do
    @block.should_not be_valid
  end
end

describe Block, "when created with date parameters" do
  before(:each) do
    @good_opts = { :start_time => DateTime.parse("2010-07-05 16:00:00 UTC"),
      :end_time => DateTime.parse("2010-07-05 18:00:00 UTC"),
	    :event => Event.create }
    @bad_opts = { :start_time => DateTime.parse("2010-07-05 18:00:00 UTC"),
      :end_time => DateTime.parse("2010-07-05 16:00:00 UTC") }
  end

  it "should accept valid parameters" do
    block = Block.create(@good_opts)
    block.should be_valid
  end

  it "should not accept an end time before a start time" do
    block = Block.create(@bad_opts)
    block.should_not be_valid
    block.errors[:end_time].should include("must be after start time")
  end
end
