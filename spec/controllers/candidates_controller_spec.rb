require 'spec_helper'

describe CandidatesController do

  before(:each) do
    @person = mock_model(Person)
    @cand = mock_model(Candidate)
    allow(@person).to receive(:candidate) { @cand }
    allow(@person).to receive(:admin?) { false }
    allow(@person).to receive(:coursesurveys){ [] }
    login_as @person
    allow(controller).to receive(:is_candidate?) { true }
  end

  describe "GET 'portal'" do
    it "should be successful" do
      allow(@cand).to receive(:requirements_status) { {:status => {}, :rsvps => []} }
      allow(@cand).to receive(:challenges) { [] }
      allow(@person).to receive(:resumes) { [] }
      allow(@cand).to receive(:quiz_responses) { [] }

      get 'portal'
      response.should be_success
    end
  end

  describe "GET 'application'" do
    it "should be successful" do
      @suggestion = mock_model(Suggestion)
      allow(@suggestion).to receive(:suggestion) { "" }

      allow(@person).to receive(:aim) { "" }
      allow(@person).to receive(:phone_number) { "" }
      allow(@person).to receive(:local_address) { "" }
      allow(@person).to receive(:perm_address) { "" }
      allow(@person).to receive(:grad_semester) { "" }

      allow(@cand).to receive(:release)
      allow(@person).to receive(:suggestion) { @suggestion }
      allow(@cand).to receive(:committee_preferences) { [] }
      get 'application'
      response.should be_success
    end
  end

  describe "GET 'quiz'" do
    it "should be successful" do
      allow(@cand).to receive(:quiz_responses) { Hash.new }
      get 'quiz'
      response.should be_success
    end
  end

end
