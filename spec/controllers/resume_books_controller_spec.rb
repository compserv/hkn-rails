require 'spec_helper'

describe ResumeBooksController do

  before(:all) do
    ResumeBooksController.skip_before_filter :authorize_indrel
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "should be successful" do
      pending "I don't know if we actually want the LaTeX stuff to run when we hit this"
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
end
