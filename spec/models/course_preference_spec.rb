# == Schema Information
#
# Table name: course_preferences
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  tutor_id   :integer
#  level      :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe CoursePreference, "when created with blank parameters" do
  before(:each) do
    @course_preference = CoursePreference.create
  end

  it "should require a level" do
    @course_preference.should_not be_valid
    @course_preference.errors[:level].should include("can't be blank")
  end

  it "should require a tutor" do
    @course_preference.should_not be_valid
    @course_preference.errors[:tutor].should include("can't be blank")
  end

  it "should require a course" do
    @course_preference.should_not be_valid
    @course_preference.errors[:course].should include("can't be blank")
  end
end

describe CoursePreference do
  before(:each) do
    @good_opts = {
      :tutor => mock_model(Tutor),
      :course => mock_model(Course),
      :level => 1
    }
    @bad_opts = {
      :tutor => mock_model(Tutor),
      :course => mock_model(Course),
      :level => 3
    }
  end

  it "should accept valid parameters" do
    cp = CoursePreference.create(@good_opts)
    cp.should be_valid
  end

  it "should require level to be within 0..2" do
    cp = CoursePreference.create(@bad_opts)
    cp.should_not be_valid
  end
end
