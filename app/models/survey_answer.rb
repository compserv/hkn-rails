# == Schema Information
#
# Table name: survey_answers
#
#  id                 :integer          not null, primary key
#  survey_question_id :integer          not null
#  frequencies        :string(255)      not null
#  mean               :float
#  deviation          :float
#  median             :float
#  order              :integer
#  instructorship_id  :integer          not null
#

class SurveyAnswer < ActiveRecord::Base
  include CoursesurveysHelper

  belongs_to :instructorship
  belongs_to :survey_question

  has_one :instructor, through: :instructorship
  has_one :klass,      through: :instructorship
  has_one :course,     through: :klass

  validates_presence_of :instructorship
  validates_presence_of :survey_question


  def recompute_stats!
    return unless frequencies

    f = decode_frequencies(self.frequencies)

    # We can use these as temps for now..
    self.mean = self.median = self.deviation = 0

    # Counters
    num_scores = f.values.reduce{|a,b|a+b}
    if f.keys.include? 'N/A'
      num_scores -= f['N/A']
    end
    if f.keys.include? 'Omit'
      num_scores -= f['Omit']
    end
    if num_scores == 0
      self.update_attributes(mean: 0, median: 0, deviation: 0)
      return
    end
    median_counter = num_scores/2

    # Compute mean & median
    (1..self.survey_question.max).each do |score|
        # mean
        self.mean += score*f[score] if f.keys.include? score

        # median
        if self.median == 0 then
            median_counter -= f[score]
            self.median = score if median_counter <= 0
        end
    end # 1..max
    self.mean /= num_scores.to_f

    # std dev relies on mean, so we have to do it last
    (1..self.survey_question.max).each do |score|
        self.deviation += (score-self.mean)**2 * f[score]
    end
    self.deviation = Math.sqrt(self.deviation/num_scores.to_f)

#    self.update_attributes(mean: self.mean, median: self.median, deviation: self.deviation)
    self.save!

  end #recompute_stats!

  def confidence_interval
    return unless frequencies
#    k = "survey_answer/#{self.id}/confidence_interval"
#    v = Rails.cache.read(k)
#    return v if v
    v = 1.96*self.deviation/Math.sqrt(ActiveSupport::JSON.decode(frequencies).values.reduce{|x,y| x.to_i+y.to_i})
    v = 0 if v.to_f.nan? || v.to_f.infinite?
#    Rails.cache.write(k, v)
#    v
  end
end
