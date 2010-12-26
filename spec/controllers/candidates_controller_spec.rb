require 'spec_helper'

describe CandidatesController do

  before(:each) do
    @person = mock_model(Person)   
    @cand = mock_model(Candidate)
    @person.stub!(:candidate).and_return(@cand)
    @person.stub!(:admin?).and_return(false)
    #controller.stub!(:current_user).and_return(@person)
    login_as @person
    controller.stub!(:is_candidate?).and_return(true)
  end
  
  describe "GET 'portal'" do
    it "should be successful" do
      @cand.stub!(:requirements_status).and_return(Hash.new)
      get 'portal'
      response.should be_success
    end
  end

  describe "GET 'application'" do
    it "should be successful" do
      get 'application'
      response.should be_success
    end
  end

  describe "GET 'quiz'" do
    it "should be successful" do
      get 'quiz'
      response.should be_success
    end
  end

end
