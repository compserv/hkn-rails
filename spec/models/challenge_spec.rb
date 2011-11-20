require 'spec_helper'

describe Challenge do

  describe "status string" do

    it "should correctly determine Confirmed, Rejected, Pending" do
      {
        Challenge::CONFIRMED => 'Confirmed',
        Challenge::PENDING   => 'Pending',
        Challenge::REJECTED  => 'Rejected'
      }.each_pair do |status, str|
        c = stub_model(Challenge, :status => status)
        c.get_status_string.should == str
      end
    end

  end

end
