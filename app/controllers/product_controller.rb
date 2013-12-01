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

    if @product.update_attributes(params[:product].except(:image))
    else
      render 'edit'
      return
    end

    img_path = "public/pictures/product_images/#{@product.id}.png"
    unless img = params[:product][:image]
      flash[:notice] = "Please attach picture"
      render 'edit'
      return
    end
    File.open(img_path,"wb") do |f|
      f.write(img.read)
    end
    @product.image = "/pictures/product_images/#{@product.id}.png"
    
    @product.save
    flash[:notice] = "Saved"
    redirect_to show_path(@product) 

  end

  def destroy
    @product = Sellable.find(params[:pid])
    @product.destroy
    redirect_to store_path
  end

end
