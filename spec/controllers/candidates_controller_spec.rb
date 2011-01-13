require 'spec_helper'

describe CandidatesController do

  before(:each) do
    @person = mock_model(Person)   
    @cand = mock_model(Candidate)
    @person.stub!(:candidate).and_return(@cand)
    @person.stub!(:admin?).and_return(false)
    @person.stub!(:coursesurveys).and_return([])
    #controller.stub!(:current_user).and_return(@person)
    login_as @person
    controller.stub!(:is_candidate?).and_return(true)
  end
  
  describe "GET 'portal'" do
    it "should be successful" do
      @cand.stub!(:requirements_status).and_return({:status => {}, :rsvps => []})
      @cand.stub!(:challenges).and_return([])
      @person.stub!(:resumes).and_return([])
      @cand.stub!(:quiz_responses).and_return([])
      
      get 'portal'
      response.should be_success
    end
  end

  describe "GET 'application'" do
    it "should be successful" do
      @suggestion = mock_model(Suggestion)
      @suggestion.stub!(:suggestion).and_return("")
      
      @person.stub!(:aim).and_return("")
      @person.stub!(:phone_number).and_return("")
      @person.stub!(:local_address).and_return("")
      @person.stub!(:perm_address).and_return("")
      @person.stub!(:grad_semester).and_return("")
      
      @cand.stub!(:release)
      @person.stub!(:suggestion).and_return(@suggestion)
      @cand.stub!(:committee_preferences).and_return([])
      get 'application'
      response.should be_success
    end
  end

  describe "GET 'quiz'" do
    it "should be successful" do
      @cand.stub!(:quiz_responses).and_return(Hash.new)
      get 'quiz'
      response.should be_success
    end
  end

end
