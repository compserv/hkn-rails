class LineItemsController < ApplicationController

  def create
    @product = Sellable.find(params[:pid])
    @line_item = LineItem.create!(:cart => current_cart, :sellable => @product, :quantity => 1, :unit_price => @product.price)
    flash[:notice] = "Added #{@product.name} to cart."
    redirect_to cart_path(id: current_cart.id)
  end

end
