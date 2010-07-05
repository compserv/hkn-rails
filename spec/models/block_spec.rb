require 'spec_helper'

describe Block, "when created with blank parameters" do
  before(:each) do
    @block = Block.create
  end

  it "should not require any fields to be valid" do
    @block.should be_valid
  end

  it "should" do
    
  end
end

describe Block, "when created with date parameters" do
  before(:each) do
    @good_opts = {:start_time => DateTime.parse("2010-07-05 16:00:00 UTC"),
      :end_time => DateTime.parse("2010-07-05 18:00:00 UTC")}
    @bad_opts = {:start_time => DateTime.parse("2010-07-05 18:00:00 UTC"),
      :end_time => DateTime.parse("2010-07-05 16:00:00 UTC")}
  end

  it "should accept valid parameters" do
    block = Block.create(@good_opts)
    block.should be_valid
  end

  it "should not accept an end time before a start time" do
    block = Block.create(@bad_opts)
    block.should_not be_valid
    block.errors[:base].should include("Start time must be less than end time")
  end
end
