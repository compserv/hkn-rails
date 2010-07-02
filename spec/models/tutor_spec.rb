require 'spec_helper'

describe Tutor, "when created with blank parameters" do
  before(:each) do
    @tutor = Tutor.create
  end

  it "should require a person" do
    @tutor.should_not be_valid
    @tutor.errors[:person].should include("can't be blank")
  end
end

describe Tutor do
  before(:each) do
    @person = mock_model(Person)
    @tutor = Tutor.create(:person => @person)
  end

  it "should be valid when supplying a candidate" do
    @tutor.should be_valid
  end

  describe "with courses" do
    it "should have reference to its courses" do
      @course = Course.create(:tutor => @tutor, :number => "1")
      @tutor.courses.should include (@course)
    end
  end

  describe "with slots" do
    it "should have a reference to its slots" do
      @slot = Slot.create(:tutor => @tutor, :number => "1")

      @tutor.slot.should include(@slot)
    end
  end
end
