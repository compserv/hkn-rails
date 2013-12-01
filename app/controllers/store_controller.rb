class StoreController < ApplicationController
  def index
  	@products = Sellable.all
  end

end
