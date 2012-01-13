require 'spec_helper'

describe PeopleController do
  describe "create" do
    def do_create(opts={})
      post 'create', {:person => good_opts}.merge(opts)
    end

    let(:good_opts) do
      {
        :first_name => "Joe",
        :last_name => "Schmoe",
        :email => "joe@example.com",
        :username => "joe",
        :password => "12345678",
        :password_confirmation => "12345678"
      }
    end

    it "creates a valid new person if input parameters are valid" do
      do_create
      assigns(:person).should be_valid
    end

    it "should not accept a parameter for :approved" do
      do_create :person => good_opts.merge(:approved => true)
      assigns(:person).approved.should_not eq(true)
    end
  end
end
