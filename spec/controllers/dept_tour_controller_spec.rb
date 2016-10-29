require 'spec_helper'

describe DeptTourController do

  describe "GET 'signup'" do
    it "should be successful" do
      get 'signup'
      response.should be_success
    end
  end

  describe "POST 'signup'" do
    before :each do
      d = (DateTime.now.utc + 1.week).beginning_of_day
      @good_params = {
        :email              => 'babakuemasta@berkeley.edu',
        :email_confirmation => 'babakuemasta@berkeley.edu',
        :name               => 'Babakue Masta',
        :phone              => '666-6666',
        :date               => (d + 11.hours).to_s
      }
    end

    it "should be successful with valid input" do
      post 'signup', @good_params
      assigns(:errors).should == {}
      response.should redirect_to dept_tour_success_path
    end

    it "should not accept invalid input" do
      bad_params = {
        :email              => "not an!!!!~~`email@WTFFFFFMAN",
        :email_confirmation => "LOLOOL",
        :name               => "",
        :phone              => "",
        :date               => Date.today.to_s
      }
      post 'signup', @good_params.update(bad_params)
      response.should_not redirect_to dept_tour_success_path
      response.should be_success # since it returned to the same page with an error message
      (bad_params.keys - assigns(:errors).keys).should == []  # all bad_params should be called out in @errors
    end
  end # POST signup

  describe "GET 'success'" do
    it "should be successful" do
      get 'success'
      response.should be_success
    end
  end

end
