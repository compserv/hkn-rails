# == Schema Information
#
# Table name: approved_emails
#
#  id                  :integer          not null, primary key
#  email               :string(255)      not null
#

class ApprovedEmails < ActiveRecord::Base
  validates :email,  presence: true

  module Validation
    module Regex
      Email = /\A[a-zA-Z0-9._+]+@berkeley\.edu\z/i
    end
  end

  validates_format_of :email,     with: Validation::Regex::Email,
                                  allow_nil: false,
                                  allow_blank: false,
                                  message: 'must be a valid @berkeley.edu email'
end

