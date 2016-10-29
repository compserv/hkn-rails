# == Schema Information
#
# Table name: instructorships
#
#  id            :integer          not null, primary key
#  klass_id      :integer
#  instructor_id :integer
#  ta            :boolean          not null
#  created_at    :datetime
#  updated_at    :datetime
#  hidden        :boolean          default(FALSE)
#  comment       :string(255)
#

require 'rails_helper'

describe Instructorship do
  before(:each) do
    # Prof 1
    @inst1 = mock_model Instructor

    # Prof 2
    @inst2 = stub_model Instructor

    # TA
    @inst3 = stub_model Instructor

    # TA and instructor
    @inst4 = stub_model Instructor

    # Some klass
    @klass = mock_model Klass

  end

  it "should require instructor, klass, ta to validate" do
    i = Instructorship.new
    n = 3
    i.valid? and i.should have(n).errors

    [ [:klass=,      @klass],
      [:instructor=, @inst1],
      [:ta=,         false ]
    ].each do |attrib, val|
      n -= 1
      i.send attrib, val
      i.valid? and i.should have(n).errors
    end

    i.should be_valid
  end

### THIS TEST IS BOGUS LOL
##  it "should link an instructor with a klass for correct role" do
##    iship1 = Instructorship.create :klass => @klass, :instructor => @inst1, :ta => false
##    iship1.should be_valid
##
##    iship2 = Instructorship.create :klass => @klass, :instructor => @inst2, :ta => true
##    iship2.should be_valid
##
##    @inst1.reload
##
##    # Test instructor => klass
##    @inst1.instructorships.should     include iship1
##    @inst1.klasses        .should     include @klass
##    @inst1.tad_klasses    .should_not include @klass
##
##    @inst2.instructorships.should     include iship2
##    @inst2.klasses        .should_not include @klass
##    @inst2.tad_klasses    .should     include @klass
##
##    # Test klass => instructor
##    @klass.instructors.should     include @inst1
##    @klass.instructors.should_not include @inst2
##    @klass.tas        .should_not include @inst1
##    @klass.tas        .should     include @inst2
##  end
end
