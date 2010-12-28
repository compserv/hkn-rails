require "spec_helper"

describe DeptTourRequestsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/dept_tour_requests" }.should route_to(:controller => "dept_tour_requests", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/dept_tour_requests/new" }.should route_to(:controller => "dept_tour_requests", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/dept_tour_requests/1" }.should route_to(:controller => "dept_tour_requests", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/dept_tour_requests/1/edit" }.should route_to(:controller => "dept_tour_requests", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/dept_tour_requests" }.should route_to(:controller => "dept_tour_requests", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/dept_tour_requests/1" }.should route_to(:controller => "dept_tour_requests", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/dept_tour_requests/1" }.should route_to(:controller => "dept_tour_requests", :action => "destroy", :id => "1")
    end

  end
end
