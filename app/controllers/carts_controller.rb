class CartsController < ApplicationController
  # def new
  #   @cart = Cart.new
  # end

  # def create
  #   @cart = Cart.new(params[:cart])
  #   if @cart.save
  #     redirect_to root_url, :notice => "Successfully created cart."
  #   else
  #     render :action => 'new'
  #   end
  # end

  def show
    @cart = current_cart
  end

end
