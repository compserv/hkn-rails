require 'spec_helper'

describe Slot, "when created with blank parameters" do
  before(:each) do
    @slot = Slot.create
  end

  it "should require time" do
    @slot.should_not be_valid
    @slot.errors[:time].should include("can't be blank")
  end

  it "should require a room" do
    @slot.should_not be_valid
    @slot.errors[:room].should include("can't be blank")
  end
end

describe Slot do
  before(:each) do
    @good_opts = {
      :time => DateTime.parse("2010-07-23 11:00:00 UTC"),
      :room => 1
    }
  end

  it "should accept valid parameters" do
    slot = Slot.create(@good_opts)
    slot.should be_valid
  end

  it "should require a valid room" do
    slot = Slot.create(@good_opts.merge(:room => 3))
    slot.should_not be_valid
    slot.errors[:room].should include("room needs to be 0 (Cory) or 1 (Soda)")
  end
end
