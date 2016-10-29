require 'spec_helper'

describe ApplicationController do
  describe "authorize" do
    context "no arguments" do
      it "rejects users who are not logged in" do
        allow(controller).to receive(:redirect_to) { }
        controller.authorize.should == false
      end

      it "allows users who are logged in" do
        allow(controller).to receive(:redirect_to) { }
        login_as double(Person)
        controller.authorize.should == true
      end
    end
  end
end
