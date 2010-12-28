require 'spec_helper'

describe Admin::TutorController, "when an officer user is logged in" do
  before :each do login_as_officer end

  describe "GET 'signup_slots'" do
    it "should be successful" do
      get 'signup_slots'
      response.should be_success
    end
  end

  pending "GET 'signup_classes'" do
    it "should be successful" do
      get 'signup_classes'
      response.should be_success
    end
  end

  describe "GET 'settings'" do
    it "should be denied" do
      get 'settings'
      response.should_not be_success
    end
  end
end


describe Admin::TutorController, "when a tutoring officer user is logged in" do
  before :each do
	login_as_officer({'tutoring'=>true})
  end

  pending "GET 'generate_schedule'" do
    it "should be successful" do
      get 'generate_schedule'
      response.should be_success
    end
  end

  pending "GET 'view_signups'" do
    it "should be successful" do
      get 'view_signups'
      response.should be_success
    end
  end

  describe "GET 'edit_schedule'" do
    it "should be successful" do
      get 'edit_schedule'
      response.should be_success
    end
  end

  describe "GET 'settings'" do
    it "should be successful" do
      get 'settings'
      response.should be_success
    end
  end
end

describe Admin::TutorController, "when no user is logged in" do
  it "should redirect to the login page" do
    get 'settings'
    response.should redirect_to(:login)
  end
end
