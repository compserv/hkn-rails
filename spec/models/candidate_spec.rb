require 'spec_helper'

describe Candidate, "when created with blank parameters" do
  before(:each) do
    @candidate = Candidate.create
  end

  it "should require a person" do
    @candidate.should_not be_valid
    @candidate.errors[:person].should include("can't be blank")
  end
end

describe Candidate do
  before(:each) do
    @person = mock_model(Person)
    @candidate = Candidate.create(:person => @person)
  end

  it "should be valid when supplying a person" do
    @candidate.should be_valid
  end

  describe "with quiz responses" do
    it "should have a reference to its quiz responses" do
      @qr = QuizResponse.create(:candidate => @candidate, :number => "1")
      @candidate.quiz_responses.should include(@qr)
    end

    it "should not have references to other candidates' quiz responses" do
      @qr = QuizResponse.create(:candidate_id => (@candidate.id + 1), :number => "1")
      @candidate.quiz_responses.should_not include(@qr)
    end
  end
end
