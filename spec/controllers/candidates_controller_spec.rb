require 'spec_helper'

describe CandidatesController do

  before(:each) do
    @person = mock_model(Person)   
    @cand = mock_model(Candidate)
    @person.stub(:candidate) { @cand }
    @person.stub(:admin?) { false }
    @person.stub(:coursesurveys){ [] }
    #controller.stub(:current_user) { @person }
    login_as @person
    controller.stub(:is_candidate?) { true }
  end
  
  describe "GET 'portal'" do
    it "should be successful" do
      @cand.stub(:requirements_status) { {:status => {}, :rsvps => []} }
      @cand.stub(:challenges) { [] }
      @person.stub(:resumes) { [] }
      @cand.stub(:quiz_responses) { [] }
      
      get 'portal'
      response.should be_success
    end
  end

  describe "GET 'application'" do
    it "should be successful" do
      @suggestion = mock_model(Suggestion)
      @suggestion.stub(:suggestion) { "" }
      
      @person.stub(:aim) { "" }
      @person.stub(:phone_number) { "" }
      @person.stub(:local_address) { "" }
      @person.stub(:perm_address) { "" }
      @person.stub(:grad_semester) { "" }
      
      @cand.stub(:release)
      @person.stub(:suggestion) { @suggestion }
      @cand.stub(:committee_preferences) { [] }
      get 'application'
      response.should be_success
    end
  end

  describe "GET 'quiz'" do
    it "should be successful" do
      @cand.stub(:quiz_responses) { Hash.new }
      get 'quiz'
      response.should be_success
    end
  end

end
