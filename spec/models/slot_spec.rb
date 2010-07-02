require 'spec_helper'

describe Slot, "when created with blank parameters" do
  before(:each) do
    @slot = Slot.create
  end
end

describe Slot do
  before(:each) do
    @slot = Slot.create
  end

  it "with tutors" do
    pending("fix")
    @tutor = Tutor.create(:slot => @slot, :number => "1")
    @slot.tutors.should include (@tutor)
  end

  it "with slot changes" do
    pending("fix")
    @slot_change = SlotChange.create(:slot => @slot, :number => "1")
    @slot.slot_change.should include(@slot_change)
  end
end
