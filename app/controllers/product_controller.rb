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

    if image_info = params[:product][:image_info]
      File.open(img_location(params[:pid]),"wb") do |f|
        f.write(image_info.read)
      end
      params[:product][:image] = create_image_field params[:pid]
    else
      flash[:notice] = "Please attach picture"
      render 'new'
      return
    end

    # Now we can create a record
    @product = Sellable.new(params[:product].except(:image_info))

    unless @product.valid?
      flash[:notice] = "Please fill out all the fields"
      render 'new'
      return
    end


    @product.save
    flash[:notice] = "Saved"
    redirect_to show_path(@product)
  end

  def edit
    @product = Sellable.find(params[:pid])
  end

  def update
    @product = Sellable.find(params[:pid])

    unless @product.update_attributes(params[:product].except(:image_info))
      render 'edit'
      return
    end

    if image_info = params[:product][:image_info]
      load_image(@product, image_info)
    end

    @product.save
    flash[:notice] = "Saved"
    redirect_to show_path(@product) 

  end

  def destroy
    @product = Sellable.find(params[:pid])
    @product.destroy
    redirect_to store_path
  end


  private
  def load_image(product, image_info)
    File.open(product.image_location(),"wb") do |f|
      f.write(image_info.read)
    end
  end

  def img_location(pid)
    "public/pictures/product_images/#{pid}.png"
  end

  def create_image_field(pid)
    "/pictures/product_images/#{pid}.png"
  end

end
