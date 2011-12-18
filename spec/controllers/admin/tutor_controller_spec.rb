require 'spec_helper'

describe Admin::TutorController, "when an officer user is logged in" do
  before :each do 
    login_as_officer 
    tutor = mock_model(Tutor, :availabilities => [], :adjacency => 1)
    @current_user.stub(:tutor) { tutor }
  end

  describe "GET 'signup_slots'" do
    before :each do
      @defaults = {wday: 1, hour: 11, preference_level: 0, room_strength: 0, preferred_room: 0}
    end

    it "should be successful" do
      get 'signup_slots'
      response.should be_success
    end

    it "should set @prefs with preference levels" do
      avs = [
        mock_model(Availability, @defaults.merge(wday: 2, hour: 14, preference_level: 2)),
        mock_model(Availability, @defaults.merge(wday: 3, hour: 14, preference_level: 0)),
      ]
      @current_user.tutor.stub(:availabilities) { avs }
      get 'signup_slots'
      assigns(:prefs)[2][14].should eq(2)
      assigns(:prefs)[3][14].should eq(0)
    end

    it "should set @sliders with slider values" do
      avs = [
        mock_model(Availability, @defaults.merge(wday: 2, hour: 14, preferred_room: 0, room_strength: 1)),
        mock_model(Availability, @defaults.merge(wday: 3, hour: 14, preferred_room: 1, room_strength: 2)),
      ]
      @current_user.tutor.stub(:availabilities) { avs }
      get 'signup_slots'
      assigns(:sliders)[2][14].should eq(1)
      assigns(:sliders)[3][14].should eq(4)
    end
  end

  describe "PUT 'update_slots'" do
    it "should be successful" do
      put 'update_slots'
      response.should redirect_to(:admin_tutor_signup_slots)
    end

    describe "Save changes" do
      def update(opts={})
        default_opts = {commit: "Save changes", availabilities: {}}
        put 'update_slots', default_opts.merge(opts)
      end

      before :each do
        tutor = @current_user.tutor
        tutor.stub(:adjacency=)
        tutor.stub(:save!)
      end

      it "sets tutor.adjacency" do
        adjacency = "1"
        @current_user.tutor.should_receive(:adjacency=).with(adjacency)
        update adjacency: adjacency
      end

      it "creates new availabilities" do
        wday = 1
        hour = 11
        pref = 'preferred'
        slider = 3
        avs = {wday => {hour => {preference_level: pref, slider: slider}}}
        Availability.should_receive(:where).and_return([])
        Availability.should_receive(:create!).with(wday: wday, 
          hour: hour, 
          preference_level: Availability::PREF[:preferred], 
          preferred_room: Availability::ROOMS[:soda], 
          room_strength: 1, 
          tutor: @current_user.tutor)
        update availabilities: avs
      end

      it "creates destroy existing availabilities which have been set to unavailable" do
        wday = 1
        hour = 11
        pref = 'unavailable'
        slider = 3
        avs = {wday => {hour => {preference_level: pref, slider: slider}}}
        av = mock_model(Availability)
        Availability.should_receive(:where).and_return([av])
        av.should_receive(:destroy)
        update availabilities: avs
      end

      it "updates existing availabilities" do
        wday = 1
        hour = 11
        pref = 'preferred'
        slider = 3
        avs = {wday => {hour => {preference_level: pref, slider: slider}}}
        av = mock_model(Availability)
        Availability.should_receive(:where).and_return([av])
        av.should_receive(:update_attributes!).with(
          preference_level: Availability::PREF[:preferred], 
          preferred_room: Availability::ROOMS[:soda], 
          room_strength: 1)
        update availabilities: avs
      end
    end

    describe "Reset all" do
      it "should destroy all availabilities for the current person" do
        avs = mock_model("Fake")
        @current_user.tutor.stub(:availabilities) { avs }
        avs.should_receive(:destroy_all)
        put 'update_slots', commit: 'Reset all'
      end
    end
  end

  describe "GET 'signup_courses'" do
    before :each do
      @current_user.tutor.stub(:courses) { [] }
    end

    it "should be successful" do
      get 'signup_courses'
      response.should be_success
    end
  end

  describe "GET 'settings'" do
    it "should be denied" do
      get 'settings'
      response.should_not be_success
    end
  end
end


describe Admin::TutorController, "when a tutoring officer user is logged in" do
  before :each do
    login_as_officer({'tutoring'=>true})
  end

  pending "GET 'generate_schedule'" do
    it "should be successful" do
      get 'generate_schedule'
      response.should be_success
    end
  end

  pending "GET 'view_signups'" do
    it "should be successful" do
      get 'view_signups'
      response.should be_success
    end
  end

  describe "GET 'edit_schedule'" do
    it "should be successful" do
      get 'edit_schedule'
      response.should be_success
    end
  end

  describe "PUT 'update_schedule'" do
    it "should be successful" do
      pending
      put 'update_schedule'
      response.should be_success
    end
  end

  describe "GET 'settings'" do
    it "should be successful" do
      get 'settings'
      response.should be_success
    end
  end
end

describe Admin::TutorController, "when no user is logged in" do
  it "should redirect to the login page" do
    get 'settings'
    response.should redirect_to(:login)
  end
end
