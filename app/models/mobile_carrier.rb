# == Schema Information
#
# Table name: mobile_carriers
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  sms_email  :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class MobileCarrier < ActiveRecord::Base
  # Check out http://www.makeuseof.com/tag/email-to-sms/
end
