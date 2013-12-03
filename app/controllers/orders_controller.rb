class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order])
    if @order.save
      redirect_to root_url, :notice => "Successfully created order."
    else
      render :action => 'new'
    end
  end
end
