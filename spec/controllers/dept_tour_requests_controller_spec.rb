require 'spec_helper'

describe DeptTourRequestsController do
  before :each do login_as_officer('deprel'=>true) end
  def mock_dept_tour_request(stubs={})
    (@mock_dept_tour_request ||= mock_model(DeptTourRequest).as_null_object).tap do |dept_tour_request|
      dept_tour_request.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all dept_tour_requests as @dept_tour_requests" do
      DeptTourRequest.stub(:all) { [mock_dept_tour_request] }
      get :index
      assigns(:dept_tour_requests).should eq([mock_dept_tour_request])
    end
  end

  describe "GET show" do
    it "assigns the requested dept_tour_request as @dept_tour_request" do
      DeptTourRequest.stub(:find).with("37") { mock_dept_tour_request }
      get :show, :id => "37"
      assigns(:dept_tour_request).should be(mock_dept_tour_request)
    end
  end

  describe "GET edit" do
    it "assigns the requested dept_tour_request as @dept_tour_request" do
      DeptTourRequest.stub(:find).with("37") { mock_dept_tour_request }
      get :edit, :id => "37"
      assigns(:dept_tour_request).should be(mock_dept_tour_request)
    end
  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested dept_tour_request" do
        DeptTourRequest.should_receive(:find).with("37") { mock_dept_tour_request }
        mock_dept_tour_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :dept_tour_request => {'these' => 'params'}
      end

      it "assigns the requested dept_tour_request as @dept_tour_request" do
        DeptTourRequest.stub(:find) { mock_dept_tour_request(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:dept_tour_request).should be(mock_dept_tour_request)
      end

      it "redirects to the dept_tour_request" do
        DeptTourRequest.stub(:find) { mock_dept_tour_request(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(dept_tour_request_url(mock_dept_tour_request))
      end
    end

    describe "with invalid params" do
      it "assigns the dept_tour_request as @dept_tour_request" do
        DeptTourRequest.stub(:find) { mock_dept_tour_request(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:dept_tour_request).should be(mock_dept_tour_request)
      end

      it "re-renders the 'edit' template" do
        DeptTourRequest.stub(:find) { mock_dept_tour_request(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested dept_tour_request" do
      DeptTourRequest.should_receive(:find).with("37") { mock_dept_tour_request }
      mock_dept_tour_request.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dept_tour_requests list" do
      DeptTourRequest.stub(:find) { mock_dept_tour_request }
      delete :destroy, :id => "1"
      response.should redirect_to(dept_tour_requests_url)
    end
  end

end
