require 'spec_helper'

describe Slot do, "when created with blank parameters" do
  before(:each) do
    @slot = Slot.create
  end
end

describe Slot do
  before(:each) do
    @slot = Slot.create
  end

  describe "with tutors" do
    @tutor = Tutor.create(:slot => @slot, :number => "1")
    @slot.tutors.should include (@tutor)
  end

  describe "with slot changes" do
    @slot_change = SlotChange.create(:slot => @slot, :number => "1")
    @slot.slot_change.should include(@slot_change)
  end
end
