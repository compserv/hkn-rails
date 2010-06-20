require 'spec_helper'

describe PropertiesController do

  def mock_property(stubs={})
    @mock_property ||= mock_model(Property, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all properties as @properties" do
      Property.stub(:all) { [mock_property] }
      get :index
      assigns(:properties).should eq([mock_property])
    end
  end

  describe "GET show" do
    it "assigns the requested property as @property" do
      Property.stub(:find).with("37") { mock_property }
      get :show, :id => "37"
      assigns(:property).should be(mock_property)
    end
  end

  describe "GET new" do
    it "assigns a new property as @property" do
      Property.stub(:new) { mock_property }
      get :new
      assigns(:property).should be(mock_property)
    end
  end

  describe "GET edit" do
    it "assigns the requested property as @property" do
      Property.stub(:find).with("37") { mock_property }
      get :edit, :id => "37"
      assigns(:property).should be(mock_property)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created property as @property" do
        Property.stub(:new).with({'these' => 'params'}) { mock_property(:save => true) }
        post :create, :property => {'these' => 'params'}
        assigns(:property).should be(mock_property)
      end

      it "redirects to the created property" do
        Property.stub(:new) { mock_property(:save => true) }
        post :create, :property => {}
        response.should redirect_to(property_url(mock_property))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved property as @property" do
        Property.stub(:new).with({'these' => 'params'}) { mock_property(:save => false) }
        post :create, :property => {'these' => 'params'}
        assigns(:property).should be(mock_property)
      end

      it "re-renders the 'new' template" do
        Property.stub(:new) { mock_property(:save => false) }
        post :create, :property => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested property" do
        Property.should_receive(:find).with("37") { mock_property }
        mock_property.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :property => {'these' => 'params'}
      end

      it "assigns the requested property as @property" do
        Property.stub(:find) { mock_property(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:property).should be(mock_property)
      end

      it "redirects to the property" do
        Property.stub(:find) { mock_property(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(property_url(mock_property))
      end
    end

    describe "with invalid params" do
      it "assigns the property as @property" do
        Property.stub(:find) { mock_property(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:property).should be(mock_property)
      end

      it "re-renders the 'edit' template" do
        Property.stub(:find) { mock_property(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested property" do
      Property.should_receive(:find).with("37") { mock_property }
      mock_property.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the properties list" do
      Property.stub(:find) { mock_property(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(properties_url)
    end
  end

end
