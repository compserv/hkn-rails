require 'spec_helper'

describe CandidatesController do

  describe "GET 'portal'" do
    it "should be successful" do
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
