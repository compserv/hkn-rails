require 'spec_helper'

describe CoursesurveysController do

  before :each do
    # Two profs, two TAs
    @inst1 = mock_model Instructor
    @inst2 = mock_model Instructor
    @ta1   = mock_model Instructor
    @ta2   = mock_model Instructor

    # Departments
    @ee    = mock_model Department, :name => 'Elektrikal Enjineering', :abbr => 'EE'

    # EE Courses
    @ee1   = mock_model Course, :course_number=>40, :department => @ee
    @ee2   = mock_model Course, :course_number=>20, :suffix=>'N', :department => @ee

    # EE Klasses
    @k1   = mock_model Klass, :course => @ee1, :semester => Property.get_or_create.semester, :section => 0
    @k2   = mock_model Klass, :course => @ee2, :semester => "19111", :section => 0

    allow(@ee1).to receive(:klasses) { @k1 }
    allow(@ee2).to receive(:klasses) { @k2 }

    # Stub things out
    allow(Department).to receive(:find) { [@ee] }
    allow(Course).to     receive(:find) { [@ee1, @ee2] }
  end

  describe "GET department" do
    it "should be successful for EE and CS" do
      [ 'EE', 'CS' ].each do |dept|
        #Klass.should_receive(:find).with any_args
        get 'department', :dept_abbr => dept
        response.should be_success
      end
    end

    it "should redirect for unknown department" do
      get 'department', :dept_abbr => 'OH MY GOOOOOOOOOOOD!'
      response.should be_redirect
    end

    it "should be RESTful" do
      { :get => '/coursesurveys/course/CS' }.should route_to(
      { :controller => 'coursesurveys',
        :action     => 'department',
        :dept_abbr  => 'CS'                })
    end

    it "should show only recent courses, by default" do
      pending "Too much dependence on things that need to be stubbed out"
      expect(@k1).to receive(:find).
          with(:first, an_instance_of(Hash)).
          and_return(@k1)
      expect(@k2).to receive(:find)

      get 'department', :dept_abbr => 'EE'

      assigns(:lower_div).should     include @ee1
      assigns(:lower_div).should_not include @ee2
    end
  end

  describe "GET course" do
    it "should get course by short name" do
      pending "Too much dependence on things that need to be stubbed out"
      get 'course', :dept_abbr => 'EE', :short_name => '40'
      response.should be_success
    end

    context "when klass is missing surveys" do
      before :each do
        allow(Course).to receive(:lookup_by_short_name) { mock_model(Course, :id => 1) }
        @klass = mock_model(Klass)
        @course = mock_model(Course, :klasses => [@klass])
        allow(Course).to receive_message_chain(:joins, :find) { @course }
        allow(SurveyQuestion).to receive(:find_by_keyword) { mock_model(SurveyQuestion, :max => 7) }
        allow(@klass).to receive_message_chain(:survey_answers, :exists?) { true }
        allow(@klass).to receive_message_chain(:survey_answers, :where) { [] }
        @instructor = mock_model(Instructor)
        allow(@klass).to receive(:instructors) { [@instructor] }
      end

      it "logs the error" do
        expect(controller.logger).to receive(:warn)
        get 'course', :dept_abbr => 'CS', :course_number => '194'
      end

      it "still renders successfully" do
        get 'course', :dept_abbr => 'CS', :course_number => '194'
        response.should be_success
      end
    end
  end

  describe "search" do
    it "should not crash" do
      get 'search'
    end
  end
end # CoursesurveysController
