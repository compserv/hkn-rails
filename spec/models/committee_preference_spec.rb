require 'rails_helper'

describe CommitteePreference, "when created with blank parameters" do
  before(:each) do
    @cp = CommitteePreference.create
  end

  it "should require a candidate" do
    @cp.should_not be_valid
    @cp.errors[:candidate].should include("can't be blank")
  end

  it "should require a committee (group)" do
    @cp.should_not be_valid
    @cp.errors[:group].should include("can't be blank")
  end
end

describe CommitteePreference do
  before(:each) do
    @candidate = mock_model(Candidate)
    @group = mock_model(Group)
    @cp = CommitteePreference.create(:candidate => @candidate, :group => @group)
  end

  it "should be valid when supplying both a candidate and a group" do
    @cp.should be_valid
  end
end
