require 'rails_helper'

describe QuizResponse, "when created with blank parameters" do
  before(:each) do
    @qr = QuizResponse.create
  end

  it "should require a candidate" do
    @qr.should_not be_valid
    @qr.errors[:candidate].should include("can't be blank")
  end

  it "should require a question number" do
    @qr.should_not be_valid
    @qr.errors[:number].should include("can't be blank")
  end
end

describe QuizResponse do
  before(:each) do
    @candidate = mock_model(Candidate)
    @qr = QuizResponse.create(:candidate => @candidate, :number => "q1")
  end

  it "should be valid when supplying both a candidate and a number" do
    @qr.should be_valid
  end

  it "should split major and minor number" do
    QuizResponse.new(:number => :q2).split_number.should == [2, nil]
    QuizResponse.new(:number => :q7_3).split_number.should == [7, 3]
  end

  context "when grading" do
    def r(number, response)
      q = QuizResponse.new(:number => number.to_s, :response => response.to_s)
    end

    # @param q [QuizResponse]
    # @param correctness [Boolean]
    def verify(q,correctness)
        q = [q] unless q.is_a? Array

        statuses = {}
        msg = nil
        correctness = !!correctness

        q.each do |qr|
          begin
            qr.grade
            statuses[qr.response] = qr.correct?
          rescue QuizResponse::IncorrectError
            statuses[qr.response] = false
          end
        end

        unless statuses.values.all? == correctness
          msg = "#{q.collect(&:response).join(', ')} should be #{correctness ? 'correct' : 'wrong'} but\n"
          msg += statuses.select {|qr,s| s!=correctness} .collect(&:first).join(', ')
          msg += "\nare #{correctness ? 'wrong' : 'correct'}"
          msg += "\n#{statuses.inspect}"
        end

        fail msg if msg
    end

    # Verifies correctness of a collection of answers.
    # @param number [String] quiz number. See {QuizResponse}
    # @param h [Hash] responses to check, of the form 'question response' => true|false,
    #   indicating whether the response should be correct or not.
    #   Pass an Array to check multiple answers.
    def check_all(number, h)
      h.each_pair do |response, correctness|
        if response.is_a? Array   # multi-reponse

          # Don't waste time if we go 4! or higher
          permutations = (response.length <= 3) ? response.permutation(response.length) : [response]

          permutations.each do |responses|
            qr = []
            c = stub_model(Candidate)
            responses.each_with_index do |resp,i|
              q = r("#{number}_#{i+1}",resp)
              q.candidate = c
              qr << q
            end
            c.quiz_responses = qr
            verify qr, correctness
          end
        else                      # single-response
          verify r(number,response), correctness
        end
      end
    end

    it "q1. HKN was founded at" do
      check_all 'q1', {
        'University of Illinois, Urbana-Champaign' => true,
        'University of Illinois Urbana Champaign' => true,
        'The University of Illinois, Urbana-Champaign' => true,
        'university of illinois at urbana-champaign' => true,
        'university of illinois' => false
      }
    end

    it "q2. HKN was founded in the year" do
      check_all 'q2', {
        '1904' => true,
        '1903' => false
      }
    end

    it "q3. Berkeley chapter is known as" do
      check_all 'q3', {
        'Mu' => true,
        'emu' => false
      }
    end

    it "q4. Berkeley chapter was established in the year" do
      check_all 'q4', {
        '1915' => true,
        '11915' => false
      }
    end

    it "q5. HKN colors" do
      check_all 'q5', {
        [ 'navy blue', 'scarlet' ] => true,
        [ 'navy-blue', 'scarlet' ] => true,
        [ 'cardinal', 'navy blue'] => false
      }
    end

    it "q6. HKN emblem" do
      check_all 'q6', {
        'wheatstone bridge'     => true,
        'the wheatstone bridge' => true,
        'wheatstone'            => false
      }
    end

    it "q7. Six officer positions" do
      check_all 'q7', {
        [ 'bridge correspondent', 'corresponding secretary', 'president', 'recording secretary', 'vice-president', 'treasurer' ] => true,
        [ 'news correspondent', 'corresponding secretary', 'president', 'recording secretary', 'vice president', 'treasurer' ] => true,
        [ 'bridge', 'csec', 'pres', 'rsec', 'vp', 'treasurer' ] => false,
        [ 'bridge correspondent', 'corresponding secretary', 'president' ] => false
      }
    end

    it "q8. Four Berkeley chapter services" do
      check_all 'q8', {
        [ 'course surveys', 'exam preparation', 'peer advising', 'tutoring' ] => true,
        [ 'coursesurveys', 'exam database', 'advising', 'tutor people' ] => true,
        [ 'do food runs', 'review sessions', 'courseguide', 'department bakeoff' ] => true,
        [ 'food runs', 'review session', 'course guide', 'department bake-off' ] => true,
        [ 'faculty retreat', 'course guide', 'department bake off', 'department tour' ] => true,
        [ 'coursesurveys', 'exams', 'peer advising' ] => false
      }
    end

    it "q9. EECS faculty who is a member" do
      check_all 'q9', {
        'Dan Garcia' => true,
            'Garcia' => true,

        'Eric Brewer' => true,
             'Brewer' => true,

        'Charles Birdsall' => true,
          'Charles K. Birdsall' => true,
          'Ned Birdsall'        => true,

        'Babak Ayazifar' => true,
            'Babak'    => true,
            'Ayazifar' => true,

        'Anant Sahai' => true,
              'Sahai' => true,

        'Ed Levin'  => false
      }
    end

    it "q10. Offices" do
      check_all 'q10', {
        [ '345 Soda', '290 Cory' ] => true,
        [ 'Soda 345', 'Cory 290' ] => true,
        [ '345 Sooda', '290 Cory' ] => false,
        [ '345 Soda', '29 Cory' ] => false,
        [ '345 Soda' ] => false
      }
    end

  end # grading

end
