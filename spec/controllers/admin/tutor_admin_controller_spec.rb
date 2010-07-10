require 'spec_helper'

describe Admin::TutorAdminController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'signup_slots'" do
    it "should be successful" do
      get 'signup_slots'
      response.should be_success
    end
  end

  describe "GET 'signup_classes'" do
    it "should be successful" do
      get 'signup_classes'
      response.should be_success
    end
  end

  describe "GET 'generate_schedule'" do
    it "should be successful" do
      get 'generate_schedule'
      response.should be_success
    end
  end

  describe "GET 'view_signups'" do
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
