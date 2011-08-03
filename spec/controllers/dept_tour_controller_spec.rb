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
      d = 1.week.since
      @good_params = {
        'email'              => 'babakuemasta@berkeley.edu',
        'email_confirmation' => 'babakuemasta@berkeley.edu',
        'name'               => 'Babakue Masta',
        'phone'              => '666-6666',
        'date'               => { 'day' => d.day.to_s, 'month' => d.month.to_s, 'year' => d.year.to_s, 'hour' => '12', 'min' => '39' }
      }
    end

    it "should be successful with valid input" do
      post 'signup', @good_params
      assigns[:errors].should == {}
      response.should redirect_to dept_tour_success_path
    end

    it "should not accept invalid input" do
      bad_params = {
        'email'              => "not an!!!!~~`email@WTFFFFFMAN",
        'email_confirmation' => "LOLOOL",
        'name'               => "",
        'phone'              => "",
        'date'               => { 'day' => Time.now.day.to_s, 'month' => Time.now.month.to_s, 'year' => Time.now.year.to_s, 'hour' => '9' }
      }
      post 'signup', @good_params.update(bad_params)
      response.should_not redirect_to dept_tour_success_path
      response.should be_success # since it returned to the same page with an error message
      (bad_params.keys - assigns[:errors].keys).should == []  # all bad_params should be called out in @errors
    end
  end # POST signup

  describe "GET 'success'" do
    it "should be successful" do
      get 'success'
      response.should be_success
    end
  end

end
