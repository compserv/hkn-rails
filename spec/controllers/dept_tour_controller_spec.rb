require 'spec_helper'

describe DeptTourController do

  describe "GET 'signup'" do
    it "should be successful" do
      get 'signup'
      response.should be_success
    end
  end

  describe "GET 'success'" do
    it "should be successful" do
      get 'success'
      response.should be_success
    end
  end

end
