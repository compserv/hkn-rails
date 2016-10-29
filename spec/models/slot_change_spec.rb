require 'rails_helper'

describe SlotChange, "when created with blank parameters" do
  before(:each) do
    @slotChange = SlotChange.create
  end

  it "should require a tutor to be valid" do
    @slotChange.should_not be_valid
    @slotChange.errors[:tutor].should include("can't be blank")
  end
end

describe SlotChange do
  before(:each) do
    @good_opts = {
      :tutor => Tutor.create(person_id: 1),
      :date => DateTime.parse("2010-07-23 11:00:00 UTC"),
      :add_sub => 1,
      :slot_id => 1
    }
  end

  it "should accept valid parameters" do
    slotChange = SlotChange.create(@good_opts)
    slotChange.should be_valid
  end

  it "should require a valid add/subtract option" do
    slotChange = SlotChange.create(@good_opts.merge(:add_sub => 3))
    slotChange.should_not be_valid
    slotChange.errors[:add_sub].should include("Must be either 0 (add) or 1 (subtract)")
  end
end
