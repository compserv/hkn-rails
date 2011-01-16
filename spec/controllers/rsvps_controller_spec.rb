require 'spec_helper'

describe RsvpsController do

  before(:each) do
    @event ||= mock_model(Event, :blocks => [], :can_rsvp? => true)
    Event.stub(:find).and_return(@event)
  end

  def mock_rsvp(stubs={})
    @mock_rsvp ||= mock_model(Rsvp, stubs).as_null_object
  end

  def do_get(action, opts={})
    get action, {:event_id => @event.id}.merge(opts)
  end

  def do_post(action, opts={})
    post action, {:event_id => @event.id}.merge(opts)
  end

  def do_put(action, opts={})
    put action, {:event_id => @event.id}.merge(opts)
  end

  def do_delete(action, opts={})
    delete action, {:event_id => @event.id}.merge(opts)
  end

  describe "GET index" do
    it "assigns all rsvps as @rsvps" do
      @event.stub(:rsvps) { [mock_rsvp] }
      do_get :index
      assigns(:rsvps).should eq([mock_rsvp])
    end
  end

  describe "GET show" do
    it "assigns the requested rsvp as @rsvp" do
      Rsvp.stub(:find).with("37") { mock_rsvp }
      do_get :show, :id => "37"
      assigns(:rsvp).should be(mock_rsvp)
    end

    it "when current user does not have permission, redirects to root" do
      Rsvp.stub(:find).with("37") { mock_rsvp }
      @event.stub(:can_rsvp?) { false }
      do_get :show, :id => "37"
      response.should redirect_to :root
    end
  end

  describe "GET new" do
    it "assigns a new rsvp as @rsvp" do
      Rsvp.stub(:new) { mock_rsvp }
      do_get :new
      assigns(:rsvp).should be(mock_rsvp)
    end
  end

  describe "GET edit" do
    it "assigns the requested rsvp as @rsvp when current_user is its owner" do
      Rsvp.stub(:find).with("37") { mock_rsvp }
      @current_user = stub_model(Person)
      mock_rsvp.stub(:person, @current_user)
      do_get :edit, :id => "37"
      assigns(:rsvp).should be(mock_rsvp)
    end

    it "fails when current_user does not own the rsvp" do
      Rsvp.stub(:find).with("37") { mock_rsvp }
      @current_user = stub_model(Person)
      lambda{do_get :edit, :id => "37"}.should raise_error
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created rsvp as @rsvp" do
        Rsvp.stub(:new).with({'these' => 'params'}) { mock_rsvp(:save => true) }
        do_post :create, :rsvp => {'these' => 'params'}
        assigns(:rsvp).should be(mock_rsvp)
      end

      it "redirects to the created rsvp" do
        Rsvp.stub(:new) { mock_rsvp(:save => true) }
        do_post :create, :rsvp => {}
        response.should redirect_to(event_url(@event))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rsvp as @rsvp" do
        Rsvp.stub(:new).with({'these' => 'params'}) { mock_rsvp(:save => false) }
        do_post :create, :rsvp => {'these' => 'params'}
        assigns(:rsvp).should be(mock_rsvp)
      end

      it "re-renders the 'new' template" do
        Rsvp.stub(:new) { mock_rsvp(:save => false) }
        do_post :create, :rsvp => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      before(:each) do
        @current_user = stub_model(Person)
        login_as @current_user
      end

      it "updates the requested rsvp" do
        Rsvp.should_receive(:find).with("37") { mock_rsvp }
        mock_rsvp.stub(:person) { @current_user }
        mock_rsvp.should_receive(:update_attributes).with({'these' => 'params'})
        do_put :update, :id => "37", :rsvp => {'these' => 'params'}
      end

      it "assigns the requested rsvp as @rsvp" do
        Rsvp.stub(:find) { mock_rsvp(:update_attributes => true) }
        mock_rsvp.stub(:person) { @current_user }
        do_put :update, :id => "1"
        assigns(:rsvp).should be(mock_rsvp)
      end

      #it "redirects to the rsvp" do
      #  Rsvp.stub(:find) { mock_rsvp(:update_attributes => true) }
      #  mock_rsvp.stub(:person) { @current_user }
      #  do_put :update, :id => "1"
      #  response.should redirect_to(event_rsvp_url(@event, mock_rsvp))
      #end
    end

    describe "with the wrong user" do
      before(:each) do
        @current_user = stub_model(Person)
        login_as @current_user
      end

      it "raises an error" do
        Rsvp.stub(:find) { mock_rsvp(:update_attributes => false) }
        lambda {do_put :update, :id => "1"}.should raise_error
      end
    end

  end

  describe "DELETE destroy" do
    describe "with the wrong user" do
      it "raises an error" do
        Rsvp.should_receive(:find).with("37") { mock_rsvp }
        lambda {do_delete :destroy, :id => "37"}.should raise_error
      end
    end

    describe "with the correct user" do
      before(:each) do
        @current_user = stub_model(Person)
        login_as @current_user
      end

      #it "destroys the requested rsvp" do
      #  Rsvp.should_receive(:find).with("37") { mock_rsvp }
      #  mock_rsvp.stub(:person) { @current_user }
      #  mock_rsvp.should_receive(:destroy)
      #  do_delete :destroy, :id => "37"
      #end

      #it "redirects to the rsvps list" do
      #  Rsvp.stub(:find) { mock_rsvp }
      #  mock_rsvp.stub(:person) { @current_user }
      #  do_delete :destroy, :id => "1"
      #  response.should redirect_to(event_rsvps_url(@event))
      #end
    end
  end

end
