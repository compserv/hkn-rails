require 'rails_helper'

describe TutorController do

  describe "GET 'schedule'" do
    it "should be successful" do
      get 'schedule'
      response.should be_success
    end
  end

end
