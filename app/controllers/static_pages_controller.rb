class StaticPagesController < ApplicationController
  # before_filter :authorize_csec
  # before_filter :set_staticpage, only: [:show, :update]

  def index
    @static_pages = StaticPage.all
  end

  def show
    @link = Shortlink.find_by_in_url(params[:url])
    if @link
      redirect_to @link.out_url, status: @link.http_status
    else
      # Treat this as a static page, as it doesn't match a Shortlink
      @static_page = StaticPage.find_by_url!(params[:url])
    end
  end

  def new
    @static_page = StaticPage.new
  end

  def create
    @static_page = StaticPage.new(staticpage_params)

    if process_staticpage_params! and @static_page.save
      @messages << "Successfully added static page."
      redirect_to admin_staticpages_show_path(*@static_page.url)
    else
      @messages << (["Validation failed:"]+@static_page.errors.full_messages).join('<br/>').html_safe
      render action: :new
    end
  end

  def edit
    @static_page = StaticPage.find_by_url!(params[:url])
  end

  def update
    url1 = @static_page.url
    unless process_staticpage_params!
      render :show
      return
    end

    if @static_page.save
      flash[:notice] = "Successfully updated static page."
      if url1 != @static_page.url
        redirect_to admin_staticpages_show_path(*@static_page.url)
        return
      end
    else
      flash[:notice] = "Validation error"
    end
    render :show
  end

private

  def static_page_params
    params.require(:static_page).permit(
      :parent_id,
      :content,
      :title,
      :url
    )
  end

  # def set_staticpage
  #   unless @static_page = StaticPage.lookup_by_short_name(params[:dept], params[:num])
  #     redirect_to (request.referer || admin_staticpages_path), notice: "No matching static page found."
  #     return false
  #   end
  # end

  # Save parameters from params[:staticpage] to @static_page
  # @return [Boolean] whether processing was successful. Flash error is set if false.
  def process_staticpage_params!
    @static_page.update_attributes static_page_params
  end
end
