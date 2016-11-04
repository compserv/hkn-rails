class Admin::StaticPagesController < ApplicationController

  before_filter :authorize_csec
  before_filter :set_staticpage, :only => [:show, :update]

  def index
    @staticpages = StaticPage.order(:title).ordered
  end

  def show
  end

  def new
    @staticpage = StaticPage.new
  end

  def create
    @staticpage = StaticPage.new(staticpage_params)

    if process_staticpage_params! and @staticpage.save
      @messages << "Successfully added static page."
      redirect_to admin_staticpages_show_path(*@staticpage.url)
    else
      @messages << (["Validation failed:"]+@staticpage.errors.full_messages).join('<br/>').html_safe
      render :action => :new
    end
  end

  def update
    url1 = @staticpage.url
    unless process_staticpage_params!
      render :show
      return
    end

    if @staticpage.save
      flash[:notice] = "Successfully updated static page."
      if url1 != @staticpage.url
        redirect_to admin_staticpages_show_path(*@staticpage.url)
        return
      end
    else
      flash[:notice] = "Validation error"
    end
    render :show
  end

private

  def staticpage_params
    params.require(:staticpage).permit(
      :parent_id,
      :content,
      :title,
      :url
    )
  end

  def set_staticpage
    unless @staticpage = StaticPage.lookup_by_short_name(params[:dept],params[:num])
      redirect_to (request.referer || admin_staticpages_path), :notice => "No matching static page found."
      return false
    end
  end

  # Save parameters from params[:staticpage] to @staticpage
  # @return [Boolean] whether processing was successful. Flash error is set if false.
  def process_staticpage_params!
    @staticpage.update_attributes staticpage_params
    return true
  end

end
