class LineItem < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  #   quantity    : integer 
  #   unit_price  : integer 
  #   cart_id     : integer 
  #   sellable_id : integer 
  # =======================

  belongs_to :cart
  belongs_to :sellable

  def full_price
    unit_price * quantity
  end
end
