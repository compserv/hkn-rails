# == Schema Information
#
# Table name: transactions
#
#  id             :integer          not null, primary key
#  amount         :integer          not null
#  charge_id      :string(255)      not null
#  description    :text
#  created_at     :datetime
#  updated_at     :datetime
#  receipt_secret :string(255)
#

class Transaction < ActiveRecord::Base
  validates :amount,    presence: true
  validates :charge_id, presence: true
end
