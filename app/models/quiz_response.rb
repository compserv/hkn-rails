class QuizResponse < ActiveRecord::Base

  # === List of columns ===
  #   id           : integer 
  #   number       : string 
  #   response     : string 
  #   candidate_id : integer 
  #   created_at   : datetime 
  #   updated_at   : datetime 
  #   correct      : boolean 
  # =======================


  class IncorrectError < StandardError; end
  class CollectivelyIncorrectError < IncorrectError; end

  belongs_to :candidate

  validates :number, :presence => true
  validates :candidate, :presence => true

  # @return [Array<Number>] +[major, minor]+
  # @example
  #   QuizResponse.new(:number => :q7_2).split_number
  #   => [7, 2]
  def split_number
    self.number.to_s.scan( /q(\d+)(?:_(\d+))?\z/ ).first.collect {|d| d.nil? ? nil : d.to_i}
  end

  # Grade single-response questions, like founding year.
  # @raise IncorrectError
  # @raise CollectivelyIncorrectError
  def grade
    raise ArgumentError unless number.present?
    r = response.strip
    self.correct = !! case self.number.to_s.scan( /(q\d+)(_\d+)?/ ).first.first.to_sym

    # HKN founding university (full name)
    when :q1
      r =~ /University of Illinois(,( )?| at | )Urbana[\s-]Champaign/i

    # HKN founding year
    when :q2
      r == '1904'

    # Berkeley chapter name
    when :q3
      r.downcase == 'mu'

    # Berkeley chapter year
    when :q4
      r == '1915'

    # Colors
    when :q5
      all_correct? :q5, 2 do |r|
        case r
        when /navy[\s-]blue/i
          1
        when /scarlet/i
          2
        else
          false
        end
      end

    # Emblem
    when :q6
      r =~ /wheatstone bridge/i

    # Six officer positions
    when :q7
      all_correct? :q7, 6 do |r|
        case r
        when /\A(bridge|news) correspondent\z/i
          1
        when /\Acorresponding secretary\z/i
          2
        when /\Afaculty advisor\z/i
          3
        when /\Apresident\z/i
          4
        when /\Arecording secretary\z/i
          5
        when /\Avice[\s-]president\z/i
          6
        when /\Atreasurer\z/i
          7
        else
          false
        end
      end

    # Four Berkeley chapter services
    when :q8
      all_correct? :q8, 4 do |r|
        case r
        when /course( )?survey/i
          1
        when /exam/i
          2
        when /tutor/i
          3
        when /advising/i
          4
        when /food run/i
          5
        when /review session/i
          6
        when /faculty retreat/i
          7
        when /course( )?guide/i
          8
        when /department bake[\s-]?off/i
          9
        when /department tour/i
          10
        else
          false
        end
      end

    # EECS faculty who is a member
    when :q9
      [ /Garcia/,
        /Brewer/,
        /Birdsall/,
        /Babak|Ayazifar/,
        /Sahai/,
        /Kamil/
      ].any? {|f| r =~ f}

    # Our offices
    when :q10
      all_correct? :q10, 2 do |r|
        case r
        when /345 Soda/i, /Soda 345/i
          1
        when /290 Cory/i, /Cory 290/i
          2
        else
          false
        end
      end

    else
      raise ArgumentError.new("Unable to verify quiz response #{self.number}")

    end

    raise IncorrectError.new("#{self.number}: '#{self.response}'") unless self.correct
    return self.correct
  end

  # Verify that a collection of responses is correct as a whole.
  # @param q_num [Symbol,String] Base question number. +:q10+ checks +:q10_1+, +:q10_2+.
  # @param num_responses [Integer] number of responses for this question
  # @yields [String] each response
  # @param block Should verify an individual response.
  #   Returned value should be an +Integer+ ID (to ensure all responses are different)
  #   if the response is correct, or +nil+ or +false+ if the response is incorrect.
  #
  def all_correct?(q_num, num_responses, &block)
    raise ArgumentError.new("No candidate") unless self.candidate

    numbers = (1..num_responses).collect {|n| [q_num.to_s, n].join('_')}
    responses = self.candidate.quiz_responses.select {|r| numbers.include? r.number} # do it this way for testing
    return false unless responses.count == num_responses

    corrects = responses.collect {|r| yield r.response}
    responses.each do |r|
      r.correct = !!(yield r.response)
      r.update_attribute :correct, r.correct unless r.new_record?
    end
    raise CollectivelyIncorrectError unless corrects.uniq.count == num_responses
    raise CollectivelyIncorrectError unless corrects.all?

    return (self.correct = !!(yield self.response))
  end

end
