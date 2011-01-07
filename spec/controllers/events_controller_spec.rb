require 'spec_helper'

describe EventsController do

  # We should actually test the authorization before filters to ensure that 
  # only the correct users have access, but this will do for now.
  # Also, all comms should be able to access the Events stuff, not just act
  before(:all) do
    EventsController.skip_before_filter :authorize_act
    EventsController.skip_before_filter :check_act
  end

  def mock_event(stubs={})
    @mock_event ||= mock_model(Event, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all events as @events" do
      Event.stub(:all) { [mock_event] }
      get :index
      assigns(:events).should eq([mock_event])
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      Event.stub(:find).with("37") { mock_event }
      get :show, :id => "37"
      assigns(:event).should be(mock_event)
    end
  end

  describe "GET new" do
    it "assigns a new event as @event" do
      Event.stub(:new) { mock_event }
      get :new
      assigns(:event).should be(mock_event)
    end
  end

  describe "GET edit" do
    it "assigns the requested event as @event" do
      Event.stub(:find).with("37") { mock_event }
      get :edit, :id => "37"
      assigns(:event).should be(mock_event)
    end
  end

  describe "POST create" do

    describe "with valid params" do

      it "assigns a newly created event as @event" do
        Event.stub(:new).with({'these' => 'params'}) { mock_event(:save => true) }
        post :create, :event => {'these' => 'params'}
        assigns(:event).should be(mock_event)
      end

      it "redirects to the created event" do
        Event.stub(:new) { mock_event(:save! => true) }
        post :create, :event => {}, :rsvp_type => "No RSVPs"
        response.should redirect_to(event_url(mock_event))
      end

      describe "with No RSVPs allowed" do
        it "does not create Blocks" do
          Event.stub(:new) { mock_event(:save! => true) }
          Block.should_not_receive(:new)
          post :create, :event => {}, :rsvp_type => "No RSVPs"
        end
      end

      describe "with Whole Event RSVPs allowed" do
        it "creates exactly one Block with the same start and end times" do
          start_time = Time.now
          end_time = Time.now + 1.minute
          rsvp_cap = 10
          @mock_event = mock_event(:save! => true, :start_time => start_time, :end_time => end_time)
          Event.stub(:new) { @mock_event }
          @mock_block = mock_model(Block, :save! => true)
          Block.stub(:new) { @mock_block }
          @mock_block.should_receive(:rsvp_cap=).with(rsvp_cap)
          @mock_block.should_receive(:event=).with(@mock_event)
          @mock_block.should_receive(:start_time=).with(start_time)
          @mock_block.should_receive(:end_time=).with(end_time)

          post :create, :event => {}, :rsvp_type => "Whole Event RSVPs", :rsvp_cap => rsvp_cap
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
          Event.stub(:new) { @mock_event }
          @mock_block = mock_model(Block, :save! => true).as_null_object
          Block.stub(:new) { @mock_block }
          @mock_block.stub(:rsvp_cap=)
          @mock_block.should_receive(:event=).exactly(3).times.with(@mock_event)

          @mock_block.should_receive(:start_time=).once.ordered.with(start_time)
          @mock_block.should_receive(:end_time=).once.ordered.with(start_time + 1.minute)

          @mock_block.should_receive(:start_time=).once.ordered.with(start_time + 1.minute)
          @mock_block.should_receive(:end_time=).once.ordered.with(start_time + 2.minutes)

          @mock_block.should_receive(:start_time=).once.ordered.with(start_time + 2.minutes)
          @mock_block.should_receive(:end_time=).once.ordered.with(start_time + 3.minutes)

          post :create, :event => {}, :rsvp_type => @rsvp_type, :uniform_blocks => true, :num_blocks => num_blocks
        end

        it "with valid manual blocks enabled creates manually specified Blocks" do
          num_blocks = 3
          @mock_event = mock_event(:save! => true)
          Event.stub(:new) { @mock_event }
          @mock_block = mock_model(Block, :save! => true).as_null_object
          #Block.stub(:new) { @mock_block }
          block0 = 'Block 0'
          block1 = 'Block 1'
          block2 = 'Block 1'

          Block.should_receive(:new).once.ordered.with(block0).and_return @mock_block
          Block.should_receive(:new).once.ordered.with(block1).and_return @mock_block
          Block.should_receive(:new).once.ordered.with(block2).and_return @mock_block
          @mock_block.should_receive(:event=).exactly(3).times.with(@mock_event)

          post :create, :event => {}, :rsvp_type => @rsvp_type, :uniform_blocks => false, :num_blocks => num_blocks, :block0 => block0, :block1 => block1, :block2 => block2
        end

        it "with invalid manual blocks enabled redirects back to new event" do
          num_blocks = 3
          @mock_event = mock_event(:save! => true)
          Event.stub(:new) { @mock_event }
          @mock_block = mock_model(Block, :save! => lambda{raise }).as_null_object
          #Block.stub(:new) { @mock_block }
          block0 = 'Block 0'
          block1 = 'Block 1'
          block2 = 'Block 1'

          post :create, :event => {}, :rsvp_type => @rsvp_type, :uniform_blocks => false, :num_blocks => num_blocks, :block0 => block0, :block1 => block1, :block2 => block2
          response.should render_template("new")
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        Event.stub(:new).with({'these' => 'params'}) { mock_event(:save => false) }
        post :create, :event => {'these' => 'params'}
        assigns(:event).should be(mock_event)
      end

      it "re-renders the 'new' template" do
        Event.stub(:new) { mock_event(:save => false) }
        post :create, :event => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested event" do
        Event.should_receive(:find).with("37") { mock_event }
        mock_event.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :event => {'these' => 'params'}
      end

      it "assigns the requested event as @event" do
        Event.stub(:find) { mock_event(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:event).should be(mock_event)
      end

      it "redirects to the event" do
        Event.stub(:find) { mock_event(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(event_url(mock_event))
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        Event.stub(:find) { mock_event(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:event).should be(mock_event)
      end

      it "re-renders the 'edit' template" do
        Event.stub(:find) { mock_event(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested event" do
      Event.should_receive(:find).with("37") { mock_event }
      mock_event.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the events list" do
      Event.stub(:find) { mock_event(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(events_url)
    end
  end

end
