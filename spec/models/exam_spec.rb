# == Schema Information
#
# Table name: exams
#
#  id          :integer          not null, primary key
#  klass_id    :integer          not null
#  course_id   :integer          not null
#  filename    :string(255)      not null
#  exam_type   :integer          not null
#  number      :integer
#  is_solution :boolean          not null
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

describe Exam, "when created with blank parameters" do
  before(:each) do
    @exam = Exam.create
  end

  it "should require a klass to be valid" do
    @exam.should_not be_valid
    @exam.errors[:klass].should include("can't be blank")
  end

  it "should require a course to be valid" do
    @exam.should_not be_valid
    @exam.errors[:course].should include("can't be blank")
  end

  it "should require a filename to be valid" do
    @exam.should_not be_valid
    @exam.errors[:filename].should include("can't be blank")
  end

  it "should require an exam_type to be valid" do
    @exam.should_not be_valid
    @exam.errors[:exam_type].should include("can't be blank")
  end

  it "should require a is_solution to be valid" do
    @exam.should_not be_valid
    @exam.errors[:is_solution].should include("is not included in the list")
  end
end

describe Exam do
  before(:each) do
    @exam = Exam.create( klass: mock_model(Klass),
      course: mock_model(Course),
      filename: 'CS3_sp10_mt3.pdf',
      is_solution: true )
    @exam.exam_type = 1
  end

  it "should be valid when supplied appropriate arguments" do
    @exam.should be_valid
  end
end
