require 'spec_helper'

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

  it "should require a type to be valid" do
    @exam.should_not be_valid
    @exam.errors[:type].should include("can't be blank")
  end

  it "should require a is_solution to be valid" do
    @exam.should_not be_valid
    @exam.errors[:is_solution].should include("can't be blank")
  end
end

describe Exam do
  before(:each) do
    @exam = Exam.create( :klass => mock_model(Klass),
      :course => mock_model(Course),
      :filename => 'CS3_sp10_mt3.pdf',
      :is_solution => true )
    @exam.type = 1
  end

  it "should be valid when supplied appropriate arguments" do
    @exam.should be_valid
  end
end