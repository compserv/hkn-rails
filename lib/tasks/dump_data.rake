require 'csv'

namespace :db do
  desc "Dump data about professor survey ratings into a CSV file"
  task :dump_prof_data do
    file = 'prof_data.csv'

    CSV.open(file, 'w') do |writer|
      writer << ["last_name", "first_name", "class", "question", "1", "2", "3", "4", "5", "6", "7"]

      SurveyAnswer.find_each do |s|
        if not s.instructorship.nil? and not s.instructorship.ta and not s.klass.nil? and not s.instructor.nil?
          freq = s.frequencies.strip().gsub(/[^0-9:,]/i, '').split(",")
          question = s.survey_question.text
          full_klass = s.klass.to_s
          last_name = s.instructor.last_name
          first_name = s.instructor.first_name
          writer << [last_name, first_name, full_klass, question, freq[0].split(":")[1].to_i,freq[1].split(":")[1].to_i,freq[2].split(":")[1].to_i, freq[3].split(":")[1].to_i, freq[4].split(":")[1].to_i, freq[5].split(":")[1].to_i, freq[6].split(":")[1].to_i]
        end
      end
    end
  end
end
