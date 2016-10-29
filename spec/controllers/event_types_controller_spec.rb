require 'spec_helper'

describe EventTypesController do

  def mock_event_type(stb=nil, ret=nil)
    (@mock_event_type ||= mock_model(EventType).as_null_object).tap do |event_type|
      allow(event_type).to receive(stb).and_return(ret) unless stb.nil?
      allow(event_type).to receive(:to_str).and_return("Test event type")
      allow(event_type).to receive(:to_ary) { |et| [et] }
    end
  end

  describe "when not logged in as authorized user" do
    it "rejects users who are not logged in" do
      allow(EventType).to receive(:all) { [mock_event_type] }
      get :index
      response.should redirect_to(:login)
    end

    it "rejects users who are not officers or cmembers" do
      allow(EventType).to receive(:all) { [mock_event_type] }
      @current_user = stub_model(Person)
      login_as @current_user
      get :index
      response.should redirect_to(:root)
    end

    it "allows officers" do
      allow(EventType).to receive(:all) { [mock_event_type] }
      @current_user = stub_model(Person)
      login_as @current_user, {'officers' => true}
      get :index
      response.should_not redirect_to(:root)
    end

    it "allows cmembers" do
      allow(EventType).to receive(:all) { [mock_event_type] }
      @current_user = stub_model(Person)
      login_as @current_user, {'cmembers' => true}
      get :index
      response.should_not redirect_to(:root)
    end
  end

  describe "when logged in as authorized user" do
    before(:each) do
      @current_user = stub_model(Person)
      login_as @current_user, {'officers' => true}
    end

    describe "GET index" do
      it "assigns all event_types as @event_types" do
        allow(EventType).to receive(:all) { [mock_event_type] }
        get :index
        assigns(:event_types).should eq([mock_event_type])
      end
    end

    describe "GET show" do
      it "assigns the requested event_type as @event_type" do
        allow(EventType).to receive(:find).with("37") { [mock_event_type] }
        get :show, :id => "37"
        assigns(:event_type).should eq([mock_event_type])
      end
    end

    describe "GET new" do
      it "assigns a new event_type as @event_type" do
        allow(EventType).to receive(:new) { [mock_event_type] }
        get :new
        assigns(:event_type).should eq([mock_event_type])
      end
    end

    describe "GET edit" do
      it "assigns the requested event_type as @event_type" do
        allow(EventType).to receive(:find).with("37") { [mock_event_type] }
        get :edit, :id => "37"
        assigns(:event_type).should eq([mock_event_type])
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "assigns a newly created event_type as @event_type" do
          allow(EventType).to receive(:new).with({'name' => 'fun'}) { mock_event_type(:save, true) }
          post :create, :event_type => {'name' => 'fun'}
          assigns(:event_type).should be(mock_event_type)
        end

        it "redirects to the created event_type" do
          allow(EventType).to receive(:new).with({'name' => 'fun'}) { mock_event_type(:save, true) }
          post :create, :event_type => {'name' => 'fun'}
          response.should redirect_to(event_type_url(mock_event_type))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_type as @event_type" do
          allow(EventType).to receive(:new).with({}) { mock_event_type(:save, false) }
          post :create, :event_type => {'these' => 'params'}
          assigns(:event_type).should be(mock_event_type)
        end

        it "re-renders the 'new' template" do
          allow(EventType).to receive(:new).with({}) { mock_event_type(:save, false) }
          post :create, :event_type => {'these' => 'params'}
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested event_type" do
          expect(EventType).to receive(:find).with("37") { mock_event_type }
          expect(mock_event_type).to receive(:update_attributes).with({'name' => 'fun'})
          put :update, :id => "37", :event_type => {'name' => 'fun'}
        end

        it "assigns the requested event_type as @event_type" do
          allow(EventType).to receive(:find).with("1") { mock_event_type(:update_attributes, true) }
          put :update, :id => "1", :event_type => {'name' => 'fun'}
          assigns(:event_type).should be(mock_event_type)
        end

        it "redirects to the event_type" do
          allow(EventType).to receive(:find).with("1") { mock_event_type(:update_attributes, true) }
          put :update, :id => "1", :event_type => {'name' => 'fun'}
          response.should redirect_to(event_type_url(mock_event_type))
        end
      end

      describe "with invalid params" do
        it "assigns the event_type as @event_type" do
          allow(EventType).to receive(:find).with("1") { mock_event_type(:update_attributes, false) }
          put :update, :id => "1", :event_type => {'these' => 'params'}
          assigns(:event_type).should be(mock_event_type)
        end

        it "re-renders the 'edit' template" do
          allow(EventType).to receive(:find).with("1") { mock_event_type(:update_attributes, false) }
          put :update, :id => "1", :event_type => {'these' => 'params'}
          response.should render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested event_type" do
        expect(EventType).to receive(:find).with("37") { mock_event_type }
        expect(mock_event_type).to receive(:destroy)
        delete :destroy, :id => "37"
      end

      it "redirects to the event_types list" do
        allow(EventType).to receive(:find) { mock_event_type }
        delete :destroy, :id => "1"
        response.should redirect_to(event_types_url)
      end
    end
  end
end
