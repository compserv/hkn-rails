class ProductController < ApplicationController
  # before_filter :authorize_admin, except: [:index, :show]

  def index
  end

  def show
    @product = Sellable.find(params[:pid])
  end

  def new
  end

  def create
    @product = Sellable.new(params[:product])
    @product.save
    redirect_to show_path(@product)
  end

  def edit
    @product = Sellable.find(params[:pid])
  end

  def update
    @product = Sellable.find(params[:pid])
    if @product.update_attributes(params[:product])
      redirect_to show_path(@product)
    else
      render 'edit'
    end
  end

  def destroy
    @product = Sellable.find(params[:pid])
    @product.destroy
    redirect_to store_path
  end

end
