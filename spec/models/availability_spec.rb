# == Schema Information
#
# Table name: availabilities
#
#  id               :integer          not null, primary key
#  tutor_id         :integer
#  preferred_room   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  preference_level :integer
#  room_strength    :integer          default(0)
#  semester         :string(255)      not null
#  hour             :integer          not null
#  wday             :integer          not null
#

require 'rails_helper'

describe Availability, "when created with blank parameters" do
  before(:each) do
    @availability = Availability.create
  end

  it "should require a tutor to be valid" do
    @availability.should_not be_valid
    @availability.errors[:tutor].should include("can't be blank")
  end

  it "should require a preference_level to be valid" do
    @availability.should_not be_valid
    @availability.errors[:preference_level].should include("can't be blank")
  end

  it "should require a hour to be valid" do
    @availability.should_not be_valid
    @availability.errors[:hour].should include("can't be blank")
  end

  it "should require a wday to be valid" do
    @availability.should_not be_valid
    @availability.errors[:wday].should include("can't be blank")
  end
end

describe Availability do
  before(:each) do
    @good_opts = {
      tutor: mock_model(Tutor),
      preference_level: 1,
      preferred_room: 1,
      hour: 11,
      wday: 1,
    }
  end

  it "should accept valid parameters" do
    availability = Availability.create(@good_opts)
    availability.should be_valid
  end

  it "should require a valid room" do
    availability = Availability.create(@good_opts.merge(preferred_room: 5))
    availability.should_not be_valid
    #availability.errors[:preferred_room].should include(Availability::ROOM_ERROR)
    availability.errors[:preferred_room].should_not be_empty
  end

  describe "range check" do

    [:wday, :hour, :room].each do |att|
      it "should pass for #{att}" do
        test_range Slot.const_get(att.to_s.capitalize)::Valid do |value, valid|
          col_att = (att == :room) ? :preferred_room : att
          opts = @good_opts.merge(col_att => value)
          a = Availability.new(opts)
          (a.valid? == valid) || raise("#{a.inspect}; #{att}=#{value}; e #{valid}, a #{a.valid?}")
          #Availability.new(@good_opts.merge(col_att => value)).valid?.should == valid
        end
      end
    end # wday, hour, room

  end

end
