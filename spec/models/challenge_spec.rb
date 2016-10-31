# == Schema Information
#
# Table name: challenges
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  description  :text
#  status       :boolean
#  candidate_id :integer
#  officer_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

describe Challenge do
  describe "status string" do
    it "should correctly determine Confirmed, Rejected, Pending" do
      {
        Challenge::CONFIRMED => 'Confirmed',
        Challenge::PENDING   => 'Pending',
        Challenge::REJECTED  => 'Rejected'
      }.each_pair do |status, str|
        c = stub_model(Challenge, status: status)
        c.get_status_string.should == str
      end
    end

    it "raises ArgumentError with a bad argument" do
      bogus_status = "wat"

      challenge = stub_model(Challenge)
      allow(challenge).to receive(:status).and_return(bogus_status)

      expect { challenge.get_status_string }.to raise_error(ArgumentError)
    end
  end

  describe "is_current_challenge?" do
    before(:each) do
      person = stub_model(Person)
      allow(Person).to receive_message_chain(:current_candidates, :find_by_id).and_return(person)

      candidate = stub_model(Candidate, person_id: 1)
      allow(Candidate).to receive_message_chain(:find_by_id).and_return(candidate)

      @challenge = stub_model(Challenge, id: 1, candidate_id: 1)
    end

    it "identifies a current challenge" do
      expect(@challenge.is_current_challenge?).to equal(true)
    end

    it "identifies a noncurrent challenge" do
      allow(Person).to receive_message_chain(:current_candidates, :find_by_id).and_return(nil)
      expect(@challenge.is_current_challenge?).to equal(false)
    end
  end
end
