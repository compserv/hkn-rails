require 'rails_helper'

describe ResumesController do

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "upload_for" do
    it "restricts access if user is not in indrel" do
      get 'upload_for', id: 1
      response.should redirect_to(login_url)
    end

    it "allows access if user is in indrel" do
      login_as_officer(indrel: true)
      get 'upload_for', id: 1
      response.should be_success
    end
  end

  describe "create" do
    it "allows a non-indrel user to upload a resume for himself" do
      login_as_officer
      allow(Person).to receive(:find).with(@current_user.id).and_return(@current_user)
      post 'create', resume: { person: @current_user.id }
      response.should_not redirect_to(root_path)
    end

    it "allows indrel users to upload a resume for a different user" do
      login_as_officer(indrel: true)
      allow(Person).to receive(:find).with(1).and_return(@current_user)
      post 'create', resume: { person: 1 }
      response.should_not redirect_to(root_path)
    end

    it "restricts access if non-indrel user tries to upload a resume for a different user" do
      login_as_officer
      post 'create', resume: { person: 1 }
      response.should redirect_to(root_path)
    end
  end
end
