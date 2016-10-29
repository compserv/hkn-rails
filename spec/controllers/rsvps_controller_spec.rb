require 'rails_helper'

describe RsvpsController do

  before(:each) do
    @event ||= mock_model(Event, :blocks => [], :can_rsvp? => true, :allows_rsvps? => true)
    expect(Event).to receive(:find).and_return(@event)

    login
    allow(@event).to receive(:can_rsvp?) { |p| true }
  end

  def mock_rsvp(stubs={})
    (@mock_rsvp ||= mock_model(Rsvp).as_null_object).tap do |rsvp|
      for method, ret in stubs
        allow(rsvp).to receive(method).and_return(ret)
      end

      allow(rsvp).to receive(:to_str).and_return("RSVP")
      allow(rsvp).to receive(:to_ary) { |r| [r] }
    end
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
      allow(@event).to receive(:rsvps) { [mock_rsvp] }
      do_get :index, :event_id => @event.id
      assigns(:rsvps).should == [mock_rsvp]
    end
  end

  describe "GET show" do
    it "assigns the requested rsvp as @rsvp" do
      allow(Rsvp).to receive(:find).with("37") { mock_rsvp }
      do_get :show, :id => "37"
      assigns(:rsvp).should == mock_rsvp
    end

    it "when current user does not have permission, redirects to root" do
      allow(Rsvp).to receive(:find).with("37") { mock_rsvp }
      allow(@event).to receive(:can_rsvp?) { false }
      do_get :show, :id => "37"
      response.should redirect_to :root
    end
  end

  describe "GET new" do
    it "assigns a new rsvp as @rsvp" do
      allow(Rsvp).to receive(:new) { mock_rsvp }
      do_get :new
      assigns(:rsvp).should be(mock_rsvp)
    end
  end

  describe "GET edit" do
    before(:each) do
      login
    end

    it "assigns the requested rsvp as @rsvp when current_user is its owner" do
      allow(Rsvp).to receive(:find).with("37") { mock_rsvp }
      allow(mock_rsvp).to receive(:person).and_return(current_user)
      do_get :edit, :id => "37"
      assigns(:rsvp).should be(mock_rsvp)
    end

    it "fails when current_user does not own the rsvp" do
      allow(Rsvp).to receive(:find).with("37") { mock_rsvp }
      allow(mock_rsvp).to receive(:person).and_return( stub_model(Person) )
      lambda{do_get :edit, :id => "37"}.should raise_error(RuntimeError)
    end
  end

  describe "POST create" do
    before :each do
      login
    end

    describe "with valid params" do
      it "assigns a newly created rsvp as @rsvp" do
        allow(Rsvp).to receive(:new).with({'comment' => ''}) { mock_rsvp(:save => true) }
        do_post :create, :rsvp => {'comment' => ''}
        assigns(:rsvp).should be(mock_rsvp)
      end

      it "redirects to the created rsvp" do
        allow(Rsvp).to receive(:new).with({'comment' => ''}) { mock_rsvp(:save => true) }
        do_post :create, :rsvp => {'comment' => ''}
        response.should redirect_to(event_url(@event))
      end

      describe "with transportation required" do
        it "should update rsvp transportation" do
          allow(Rsvp).to receive(:new).with({ 'transportation' => Rsvp::TRANSPORT_ENUM.first.last.to_s }) { mock_rsvp(:save => true) }
          do_post :create, :rsvp => {:transportation => Rsvp::TRANSPORT_ENUM.first.last}
          response.should redirect_to(event_path(@event))
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rsvp as @rsvp" do
        allow(Rsvp).to receive(:new).with({}) { mock_rsvp(:save => false) }
        do_post :create, :rsvp => {'these' => 'params'}
        assigns(:rsvp).should be(mock_rsvp)
      end

      it "re-renders the 'new' template" do
        allow(Rsvp).to receive(:new).with({}) { mock_rsvp(:save => false) }
        do_post :create, :rsvp => {'these' => 'params'}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      before(:each) do
        login
        allow(mock_rsvp).to receive(:person).and_return(current_user)
      end

      it "updates the requested rsvp" do
        expect(Rsvp).to receive(:find).with("37") { mock_rsvp }
        expect(mock_rsvp).to receive(:update_attributes).with({'comment' => ''})
        do_put :update, :id => "37", :rsvp => {'comment' => ''}
      end

      it "assigns the requested rsvp as @rsvp" do
        allow(Rsvp).to receive(:find).with("1") { mock_rsvp(:update_attributes => true) }
        do_put :update, :id => "1", :rsvp => {'comment' => ''}
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
        login
        allow(mock_rsvp).to receive(:person).and_return( stub_model(Person) )
      end

      it "raises an error" do
        allow(Rsvp).to receive(:find) { mock_rsvp(:update_attributes => false) }
        lambda {do_put :update, :id => "1"}.should raise_error(RuntimeError)
      end
    end

  end

  describe "DELETE destroy" do
    describe "with the wrong user" do
      it "raises an error" do
        expect(Rsvp).to receive(:find).with("37") { mock_rsvp }
        lambda {do_delete :destroy, :id => "37"}.should raise_error(RuntimeError)
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

  describe "confirm" do
    it "without being logged in should redirect to login" do
      unlogin
      do_get :confirm, :id => "37"
      response.should redirect_to(login_url)
    end

    it "with wrong user should raise error" do
      @current_user = stub_model(Person)
      login_as @current_user
      do_get :confirm, :id => "37"
      response.should redirect_to(root_url)
    end

    describe "with correct user" do
      before(:each) do
        @current_user = stub_model(Person)
        login_as @current_user
        expect(controller).to receive(:authorize).with(['pres','vp'])
      end

      it "should set rsvp.confirmed to Rsvp::Confirmed" do
        expect(Rsvp).to receive(:find).with("37") { mock_rsvp }
        expect(mock_rsvp).to receive(:confirmed=).with(Rsvp::Confirmed)
        expect(controller).to receive(:authorize)
        do_get :confirm, :id => "37"
      end
    end
  end

  describe "unconfirm" do
    it "without being logged in should redirect to login" do
      unlogin
      do_get :unconfirm, :id => "37"
      response.should redirect_to(login_url)
    end

    it "with wrong user should raise error" do
      @current_user = stub_model(Person)
      login_as @current_user
      do_get :unconfirm, :id => "37"
      response.should redirect_to(root_url)
    end

    describe "with correct user" do
      before(:each) do
        @current_user = stub_model(Person)
        login_as @current_user
        expect(controller).to receive(:authorize).with(['pres','vp'])
      end

      it "should set rsvp.confirmed to Rsvp::Unconfirmed" do
        expect(Rsvp).to receive(:find).with("37") { mock_rsvp }
        expect(mock_rsvp).to receive(:update_attribute).with(:confirmed, Rsvp::Unconfirmed)
        expect(controller).to receive(:authorize) # rspec sucks
        do_get :unconfirm, :id => "37"
      end
    end
  end

  describe "reject" do
    it "without being logged in should redirect to login" do
      unlogin
      do_get :reject, :id => "37"
      response.should redirect_to(login_url)
    end

    it "with wrong user should raise error" do
      @current_user = stub_model(Person)
      login_as @current_user
      do_get :reject, :id => "37"
      response.should redirect_to(root_url)
    end

    describe "with correct user" do
      before(:each) do
        @current_user = stub_model(Person)
        login_as @current_user
        expect(controller).to receive(:authorize).with(no_args).once
        expect(controller).to receive(:authorize).with(['pres','vp']).once
      end

      it "should set rsvp.confirmed to Rsvp::Rejected" do
        expect(Rsvp).to receive(:find).with("37") { mock_rsvp }
        expect(mock_rsvp).to receive(:update_attribute).with(:confirmed, Rsvp::Rejected)
        do_get :reject, :id => "37"
      end
    end
  end

end
