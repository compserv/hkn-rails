require 'spec_helper'

describe EventTypesController do

  def mock_event_type(stubs={})
    @mock_event_type ||= mock_model(EventType, stubs).as_null_object
  end

  describe "when not logged in as authorized user" do
    it "rejects users who are not logged in" do
      EventType.stub(:all) { [mock_event_type] }
      get :index
      response.should redirect_to(:login)
    end

    it "rejects users who are not officers or cmembers" do
      EventType.stub(:all) { [mock_event_type] }
      @current_user = stub_model(Person)
      login_as @current_user
      get :index
      response.should redirect_to(:root)
    end

    it "allows officers" do
      EventType.stub(:all) { [mock_event_type] }
      @current_user = stub_model(Person)
      login_as @current_user, {'officers' => true}
      get :index
      response.should_not redirect_to(:root)
    end

    it "allows cmembers" do
      EventType.stub(:all) { [mock_event_type] }
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
        EventType.stub(:all) { [mock_event_type] }
        get :index
        assigns(:event_types).should eq([mock_event_type])
      end
    end

    describe "GET show" do
      it "assigns the requested event_type as @event_type" do
        EventType.stub(:find).with("37") { mock_event_type }
        get :show, :id => "37"
        assigns(:event_type).should be(mock_event_type)
      end
    end

    describe "GET new" do
      it "assigns a new event_type as @event_type" do
        EventType.stub(:new) { mock_event_type }
        get :new
        assigns(:event_type).should be(mock_event_type)
      end
    end

    describe "GET edit" do
      it "assigns the requested event_type as @event_type" do
        EventType.stub(:find).with("37") { mock_event_type }
        get :edit, :id => "37"
        assigns(:event_type).should be(mock_event_type)
      end
    end

    describe "POST create" do

      describe "with valid params" do
        it "assigns a newly created event_type as @event_type" do
          EventType.stub(:new).with({'these' => 'params'}) { mock_event_type(:save => true) }
          post :create, :event_type => {'these' => 'params'}
          assigns(:event_type).should be(mock_event_type)
        end

        it "redirects to the created event_type" do
          EventType.stub(:new) { mock_event_type(:save => true) }
          post :create, :event_type => {}
          response.should redirect_to(event_type_url(mock_event_type))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_type as @event_type" do
          EventType.stub(:new).with({'these' => 'params'}) { mock_event_type(:save => false) }
          post :create, :event_type => {'these' => 'params'}
          assigns(:event_type).should be(mock_event_type)
        end

        it "re-renders the 'new' template" do
          EventType.stub(:new) { mock_event_type(:save => false) }
          post :create, :event_type => {}
          response.should render_template("new")
        end
      end

    end

    describe "PUT update" do

      describe "with valid params" do
        it "updates the requested event_type" do
          EventType.should_receive(:find).with("37") { mock_event_type }
          mock_event_type.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :event_type => {'these' => 'params'}
        end

        it "assigns the requested event_type as @event_type" do
          EventType.stub(:find) { mock_event_type(:update_attributes => true) }
          put :update, :id => "1"
          assigns(:event_type).should be(mock_event_type)
        end

        it "redirects to the event_type" do
          EventType.stub(:find) { mock_event_type(:update_attributes => true) }
          put :update, :id => "1"
          response.should redirect_to(event_type_url(mock_event_type))
        end
      end

      describe "with invalid params" do
        it "assigns the event_type as @event_type" do
          EventType.stub(:find) { mock_event_type(:update_attributes => false) }
          put :update, :id => "1"
          assigns(:event_type).should be(mock_event_type)
        end

        it "re-renders the 'edit' template" do
          EventType.stub(:find) { mock_event_type(:update_attributes => false) }
          put :update, :id => "1"
          response.should render_template("edit")
        end
      end

    end

    describe "DELETE destroy" do
      it "destroys the requested event_type" do
        EventType.should_receive(:find).with("37") { mock_event_type }
        mock_event_type.should_receive(:destroy)
        delete :destroy, :id => "37"
      end

      it "redirects to the event_types list" do
        EventType.stub(:find) { mock_event_type }
        delete :destroy, :id => "1"
        response.should redirect_to(event_types_url)
      end
    end

  end

end
