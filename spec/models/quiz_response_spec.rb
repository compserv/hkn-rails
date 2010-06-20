require 'spec_helper'

describe QuizResponse, "when created with blank parameters" do
  before(:each) do
    @qr = QuizResponse.create
  end

  it "should require a candidate" do
    @qr.should_not be_valid
    @qr.errors[:candidate].should include("can't be blank")
  end

  it "should require a question number" do
    @qr.should_not be_valid
    @qr.errors[:number].should include("can't be blank")
  end
end

describe QuizResponse do
  before(:each) do
    @candidate = mock_model(Candidate)
    @qr = QuizResponse.create(:candidate => @candidate, :number => "1")
  end

  it "should be valid when supplying both a candidate and a number" do
    @qr.should be_valid
  end
end
