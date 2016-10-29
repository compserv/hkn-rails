require 'rails_helper'

describe EventsController do

  # We should actually test the authorization before filters to ensure that
  # only the correct users have access, but this will do for now.
  # Also, all comms should be able to access the Events stuff, not just act
  before(:all) do
    EventsController.skip_before_filter :authorize_comms
  end

  $start_time = Time.now
  $end_time = Time.now + 1.minute

  def mock_event(stubs={})
    (@mock_event ||= mock_model(Event).as_null_object).tap do |event|
      for method, ret in stubs
        allow(event).to receive(method).and_return(ret)
      end

      allow(event).to receive(:to_str).and_return("Event")
      allow(event).to receive(:to_ary) { |e| [e] }
    end
  end

  def valid_event_params
    {
      'name' => 'Dinner',
      'location' => 'hell',
      'description' => 'Tonight, we dine in hell!',
      'event_type_id' => "1",
      'start_time' => $start_time.to_s,
      'end_time' => $end_time.to_s
    }
  end

  describe "GET index" do
    it "assigns all events as @events" do
      #Event.stub_chain(:with_permission, :paginate) { [mock_event] }
      events = [mock_event]
      allow(Event).to receive(:with_permission) { events }
      allow(events).to receive(:paginate) { events }
      get :index
      assigns(:events).should eq(events)
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      allow(Event).to receive_message_chain(:with_permission, :find) { mock_event }
      get :show, :id => "37"
      assigns(:event).should be(mock_event)
    end

    it "when current user does not have permission, redirects to root" do
      allow(Event).to receive(:with_permission).and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "37"
      response.should redirect_to(:root)
    end
  end

  describe "GET new" do
    it "assigns a new event as @event" do
      allow(Event).to receive(:new) { mock_event }
      get :new
      assigns(:event).should be(mock_event)
    end
  end

  describe "GET edit" do
    it "assigns the requested event as @event" do
      allow(Event).to receive(:find).with("37") { mock_event }
      get :edit, :id => "37"
      assigns(:event).should be(mock_event)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created event as @event" do
        allow(Event).to receive(:new).with(valid_event_params) { mock_event(:save => true) }
        post :create, :event => valid_event_params
        assigns(:event).should be(mock_event)
      end

      it "redirects to the created event" do
        allow(Event).to receive(:new).with(valid_event_params) { mock_event(:save! => true) }
        post :create, :event => valid_event_params, :rsvp_type => "No RSVPs"
        response.should redirect_to(event_url(mock_event))
      end

      describe "with No RSVPs allowed" do
        it "does not create Blocks" do
          allow(Event).to receive(:new).with(valid_event_params) { mock_event(:save! => true) }
          expect(Block).to_not receive(:new)
          post :create, :event => valid_event_params, :rsvp_type => "No RSVPs"
        end
      end

      describe "with Whole Event RSVPs allowed" do
        it "creates exactly one Block with the same start and end times" do
          rsvp_cap = 10.to_s  # params is always string
          @mock_event = mock_event(:save! => true, :start_time => $start_time, :end_time => $end_time)
          allow(Event).to receive(:new).with(valid_event_params) { @mock_event }
          @mock_block = mock_model(Block, :save! => true)
          allow(Block).to receive(:new) { @mock_block }
          expect(@mock_block).to receive(:rsvp_cap=).with(rsvp_cap)
          expect(@mock_block).to receive(:event=).with(@mock_event)
          expect(@mock_block).to receive(:start_time=).with($start_time)
          expect(@mock_block).to receive(:end_time=).with($end_time)

          post :create, :event => valid_event_params, :rsvp_type => "Whole Event RSVPs", :rsvp_cap => rsvp_cap
        end
      end

      describe "with Block RSVPs allowed" do
        before(:each) do
          @rsvp_type = "Block RSVPs"
        end

        it "with uniform blocks enabled creates uniformly distributed Blocks" do
          num_blocks = 3
          start_time = DateTime.new(2010, 1, 6, 1, 0, 0)
          end_time = start_time + 3.minutes
          @mock_event = mock_event(:save! => true, :start_time => start_time, :end_time => end_time)
          allow(Event).to receive(:new).with(valid_event_params) { @mock_event }
          @mock_block = mock_model(Block, :save! => true).as_null_object
          allow(Block).to receive(:new) { @mock_block }
          allow(@mock_block).to receive(:rsvp_cap=)
          expect(@mock_block).to receive(:event=).exactly(3).times.with(@mock_event)

          expect(@mock_block).to receive(:start_time=).once.ordered.with(start_time)
          expect(@mock_block).to receive(:end_time=).once.ordered.with(start_time + 1.minute)

          expect(@mock_block).to receive(:start_time=).once.ordered.with(start_time + 1.minute)
          expect(@mock_block).to receive(:end_time=).once.ordered.with(start_time + 2.minutes)

          expect(@mock_block).to receive(:start_time=).once.ordered.with(start_time + 2.minutes)
          expect(@mock_block).to receive(:end_time=).once.ordered.with(start_time + 3.minutes)

          post :create, :event => valid_event_params, :rsvp_type => @rsvp_type, :uniform_blocks => true, :num_blocks => num_blocks
        end

        it "with valid manual blocks creates manually specified Blocks" do
          num_blocks = 3
          @mock_event = mock_event(:save! => true)
          allow(Event).to receive(:new).with(valid_event_params) { @mock_event }
          @mock_block = mock_model(Block, :save! => true).as_null_object
          block_params = { 'start_time' => $start_time.to_s, 'end_time' => $end_time.to_s }

          expect(Block).to receive(:new).once.ordered.with(block_params).and_return @mock_block
          expect(Block).to receive(:new).once.ordered.with(block_params).and_return @mock_block
          expect(Block).to receive(:new).once.ordered.with(block_params).and_return @mock_block
          expect(@mock_block).to receive(:event=).exactly(3).times.with(@mock_event)

          post :create, :event => valid_event_params, :rsvp_type => @rsvp_type, :uniform_blocks => false, :num_blocks => num_blocks, :block0 => block_params, :block1 => block_params, :block2 => block_params
        end

        it "with invalid manual blocks redirects back to new event" do
          num_blocks = 3
          @mock_event = mock_event(:save! => true)
          allow(Event).to receive(:new).with(valid_event_params) { @mock_event }
          @mock_block = mock_model(Block).as_null_object
          expect(@mock_block).to receive(:save!).and_raise("Block Error")
          allow(Block).to receive(:new) { @mock_block }
          block_params = { 'start_time' => $start_time.to_s, 'end_time' => $end_time.to_s }

          post :create, :event => valid_event_params, :rsvp_type => @rsvp_type, :uniform_blocks => false, :num_blocks => num_blocks, :block0 => block_params, :block1 => block_params, :block2 => block_params
          response.should render_template("new")
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        allow(Event).to receive(:new).with({}) { mock_event(:save => false) }
        post :create, :event => {'these' => 'params'}
        assigns(:event).should be(mock_event)
      end

      it "re-renders the 'new' template" do
        allow(Event).to receive(:new).with({}) { mock_event(:save => false) }
        post :create, :event => {'these' => 'params'}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event" do
        expect(Event).to receive(:find).with("37") { mock_event }
        expect(mock_event).to receive(:update_attributes).with(valid_event_params)
        put :update, :id => "37", :event => valid_event_params
      end

      it "assigns the requested event as @event" do
        allow(Event).to receive(:find).with("1") { mock_event(:update_attributes! => true) }
        put :update, :id => "1", :event => valid_event_params
        assigns(:event).should be(mock_event)
      end

      it "redirects to the event" do
        allow(Event).to receive(:find).with("1") { mock_event(:update_attributes! => true) }
        put :update, :id => "1", :rsvp_type => "No RSVPs", :event => valid_event_params
        response.should redirect_to(event_url(mock_event))
      end

      describe "with No RSVPs" do
        it "deletes all existing blocks and RSVPs" do
          @mock_event = mock_event(:update_attributes! => true)
          allow(Event).to receive(:find).with("1") { @mock_event }
          @mock_blocks = double().as_null_object
          allow(@mock_blocks).to receive(:delete_all).and_return(true)
          allow(@mock_event).to receive(:blocks) { @mock_blocks }
          expect(@mock_blocks).to receive(:delete_all)
          @mock_rsvps = double().as_null_object
          allow(@mock_event).to receive(:rsvps) { @mock_rsvps }
          expect(@mock_rsvps).to receive(:delete_all)
          put :update, :id => "1", :rsvp_type => "No RSVPs", :event => valid_event_params
        end
      end

      describe "with Whole Event RSVPs" do
        describe "if event used to have Block RSVPs" do
          it "deletes all existing blocks" do
            @mock_event = mock_event(:update_attributes! => true)
            allow(Event).to receive(:find).with("1") { @mock_event }
            # New block should save correctl
            @mock_block = mock_model(Block).as_null_object
            expect(@mock_block).to receive(:save!).and_return(true)
            allow(Block).to receive(:new) { @mock_block }
            # Existing blocks
            @mock_blocks = double().as_null_object
            allow(@mock_blocks).to receive(:delete_all).and_return(true)
            allow(@mock_event).to receive(:blocks) { @mock_blocks }
            expect(@mock_blocks).to receive(:delete_all)

            put :update, :id => "1", :rsvp_type => "Whole Event RSVPs", :event => valid_event_params
          end

          it "creates one block with the same start and end times" do
            rsvp_cap = 10.to_s  # params are always strings

            @mock_event = mock_event(:update_attributes! => true, :start_time => $start_time, :end_time => $end_time)
            @mock_blocks = double().as_null_object
            allow(@mock_event).to receive(:blocks) { @mock_blocks }
            allow(Event).to receive(:find).with("1") { @mock_event }
            @mock_block = mock_model(Block, :save! => true)
            allow(@mock_blocks).to receive(:delete_all).and_return(true)
            allow(Block).to receive(:new) { @mock_block }

            expect(@mock_block).to receive(:rsvp_cap=).with(rsvp_cap)
            expect(@mock_block).to receive(:event=).with(@mock_event)
            expect(@mock_block).to receive(:start_time=).with($start_time)
            expect(@mock_block).to receive(:end_time=).with($end_time)

            put :update, :id => "1", :rsvp_type => "Whole Event RSVPs", :rsvp_cap => rsvp_cap, :event => {:start_time => $start_time, :end_time => $end_time}
          end
        end

        describe "if event used to have Whole Event RSVPs" do
          it "does not create a new block" do
            @mock_event = mock_event(:update_attributes! => true)
            allow(Event).to receive(:find).with("1") { @mock_event }
            @mock_block = mock_model(Block, :save! => true)
            allow(@mock_block).to receive(:rsvp_cap=)
            allow(@mock_block).to receive(:event=)
            allow(@mock_block).to receive(:start_time=)
            allow(@mock_block).to receive(:end_time=)
            @mock_blocks = [@mock_block]
            allow(@mock_event).to receive(:blocks) { @mock_blocks }
            expect(Block).to_not receive(:new)

            put :update, :id => "1", :rsvp_type => "Whole Event RSVPs", :event => valid_event_params
          end

          it "updates the existing block start and end times" do
            rsvp_cap = 10.to_s  # params are always strings

            @mock_event = mock_event(:update_attributes! => true, :start_time => $start_time, :end_time => $end_time)
            allow(Event).to receive(:find).with("1") { @mock_event }
            @mock_block = mock_model(Block, :save! => true)
            allow(@mock_block).to receive(:rsvp_cap=)
            allow(@mock_block).to receive(:event=)
            expect(@mock_block).to receive(:start_time=).with($start_time)
            expect(@mock_block).to receive(:end_time=).with($end_time)
            @mock_blocks = [@mock_block]
            allow(@mock_event).to receive(:blocks) { @mock_blocks }
            expect(Block).to_not receive(:new)

            put :update, :id => "1", :rsvp_type => "Whole Event RSVPs", :event => {:start_time => $start_time, :end_time => $end_time}
          end
        end
      end

      describe "with Block RSVPs" do
        it "deletes all existing blocks which are not specified" do
          num_blocks = 3
          @mock_event = mock_event(:update_attributes! => true)
          allow(Event).to receive(:find) { @mock_event }
          @mock_block0 = mock_model(Block, :save! => true).as_null_object
          @mock_block1 = mock_model(Block, :save! => true).as_null_object
          @mock_block2 = mock_model(Block, :save! => true).as_null_object
          block0 = {:id => 0}
          block1 = {:id => 1}
          block2 = {:id => 2}
          [ [0,@mock_block0],
            [1,@mock_block1],
            [2,@mock_block2]
          ].each do |i,b|
            allow(Block).to receive(:find).with(i) { b }
          end

          allow(@mock_event).to receive(:blocks) { [@mock_block0, @mock_block1, @mock_block2] }

          expect(Block).to receive(:find).once.ordered.with(0).and_return @mock_block0
          expect(Block).to receive(:find).once.ordered.with(1).and_return @mock_block1
          expect(Block).to_not receive(:find).with(2)
          expect(@mock_block2).to receive(:delete)

          put :update, :id => "1", :event => valid_event_params, :rsvp_type => 'Block RSVPs', :uniform_blocks => false, :num_blocks => num_blocks, :block0 => block0, :block1 => block1
        end

        it "creates new blocks with correct parameters" do
          num_blocks = 3
          @mock_event = mock_event(:update_attributes! => true)
          allow(Event).to receive(:find) { @mock_event }
          @mock_block0 = mock_model(Block, :save! => true).as_null_object
          @mock_block1 = mock_model(Block, :save! => true).as_null_object
          @mock_block2 = mock_model(Block, :save! => true).as_null_object
          block0 = {:id => 0, 'start_time' => $start_time.to_s, 'end_time' => $end_time.to_s}
          block1 = {:id => 1, 'start_time' => $start_time.to_s, 'end_time' => $end_time.to_s}
          block2 = {'start_time' => $start_time.to_s, 'end_time' => $end_time.to_s}

          expect(Block).to receive(:find).once.ordered.with(0).and_return @mock_block0
          expect(Block).to receive(:find).once.ordered.with(1).and_return @mock_block1
          expect(Block).to_not receive(:find).with(2)
          expect(Block).to receive(:new).with(block2).and_return @mock_block2

          put :update, :id => "1", :event => valid_event_params, :rsvp_type => 'Block RSVPs', :uniform_blocks => false, :num_blocks => num_blocks, :block0 => block0, :block1 => block1, :block2 => block2
        end
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        allow(Event).to receive(:find) { mock_event(:update_attributes => false) }
        put :update, :id => "1", :event => { 'these' => 'params' }
        assigns(:event).should be(mock_event)
      end

      it "re-renders the 'edit' template" do
        allow(Event).to receive(:find) { mock_event(:update_attributes => false) }
        put :update, :id => "1", :event => { 'these' => 'params' }
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event" do
      expect(Event).to receive(:find).with("37") { mock_event }
      expect(mock_event).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the events list" do
      allow(Event).to receive(:find) { mock_event(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(events_url)
    end
  end

  describe "confirm_rsvps_index" do
    it "allows the president to view" do
      @current_user = stub_model(Person)
      login_as @current_user, { 'pres' => true }
      get :confirm_rsvps_index, :group => "comms"
      response.should be_success
    end

    it "allows the vice president to view" do
      @current_user = stub_model(Person)
      login_as @current_user, { 'vp' => true }
      get :confirm_rsvps_index, :group => "candidates"
      response.should be_success
    end

    it "redirects all other users" do
      @current_user = stub_model(Person)
      login_as @current_user
      get :confirm_rsvps_index, :group => "candidates"
      response.should_not be_success
      response.should redirect_to(root_url)
    end
  end

  describe "confirm_rsvps" do
    def do_confirm_rsvps
      get :confirm_rsvps, :group => "comms", :id => @event.id
    end

    before(:each) do
      @event = stub_model(Event, :rsvps => [] )
      allow(Event).to receive(:find) { @event }
    end

    it "allows the president to view" do
      @current_user = stub_model(Person)
      login_as @current_user, { 'pres' => true }
      do_confirm_rsvps
      response.should be_success
    end

    it "allows the vice president to view" do
      @current_user = stub_model(Person)
      login_as @current_user, { 'vp' => true }
      do_confirm_rsvps
      response.should be_success
    end

    it "redirects all other users" do
      @current_user = stub_model(Person)
      login_as @current_user
      do_confirm_rsvps
      response.should_not be_success
      response.should redirect_to(root_url)
    end
  end
end
