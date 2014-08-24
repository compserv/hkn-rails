class Transaction < ActiveRecord::Base
  belongs_to :company, inverse_of: :transactions  

  validates :company,
    presence: true
  validates :amount,
    presence: true
  validates :charge_id,
    presence: true

end
