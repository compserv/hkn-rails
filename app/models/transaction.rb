class Transaction < ActiveRecord::Base

  validates :amount,
    presence: true
  validates :charge_id,
    presence: true

end
