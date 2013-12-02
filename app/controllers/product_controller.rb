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

    # if image_info = params[:product][:image_info]
    #   File.open(img_location(params[:pid]),"wb") do |f|
    #     f.write(image_info.read)
    #   end
    #   params[:product][:image] = create_image_field(params[:pid])
    # else
    #   flash[:notice] = "Please attach picture"
    #   render 'new'
    #   return
    # end

    #First we check for image existence
    unless image_info = params[:product][:image_info]
      flash[:notice] = "Please attach picture"
      render 'new'
      return
    end    

    # Now we can create a record
    params[:product][:image] = create_image_field('default') #create default path
    @product = Sellable.new(params[:product].except(:image_info))

    unless @product.valid?
      flash[:notice] = "Please fill out all the fields"
      render 'new'
      return
    end
    @product.save

    # Now we can load the image and correct the image path
    if image_info
      File.open(img_location(@product.id),"wb") do |f|
        f.write(image_info.read)
      end
      @product.image = create_image_field(@product.id)
    end

    #Finally we save
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
      File.open(img_location(@product.id),"wb") do |f|
        f.write(image_info.read)
      end
      @product.image = create_image_field(@product.id)
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

  def img_location(pid)
    "public/pictures/product_images/#{pid}.png"
  end

  def create_image_field(pid)
    "/pictures/product_images/#{pid}.png"
  end

end
