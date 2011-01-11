require "spec_helper"

describe AlumnisController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/alumnis" }.should route_to(:controller => "alumnis", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/alumnis/new" }.should route_to(:controller => "alumnis", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/alumnis/1" }.should route_to(:controller => "alumnis", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/alumnis/1/edit" }.should route_to(:controller => "alumnis", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/alumnis" }.should route_to(:controller => "alumnis", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/alumnis/1" }.should route_to(:controller => "alumnis", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/alumnis/1" }.should route_to(:controller => "alumnis", :action => "destroy", :id => "1")
    end

  end
end
