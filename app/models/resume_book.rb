# == Schema Information
#
# Table name: resume_books
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  pdf_file    :string(255)
#  iso_file    :string(255)
#  directory   :string(255)
#  remarks     :string(255)
#  details     :text
#  cutoff_date :date
#  created_at  :datetime
#  updated_at  :datetime
#

class ResumeBook < ActiveRecord::Base
end
