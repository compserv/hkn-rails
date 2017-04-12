class StaticPagesController < ApplicationController
  before_action :find_static_page
  before_filter :authorize_static_pages, except: [:show]

  def index
    if @static_page
      @static_pages = @static_page.children
    else
      @static_pages = StaticPage.root_pages
    end
  end

  def show
    # Only redirect if a shortlink is found that matches
    redirect_to @link.out_url, status: @link.http_status and return if @link

    @page_content = RDiscount.new(@static_page.content).to_html or ''
  end

  def new
    @new_page = StaticPage.new
    @parents += [@static_page]
    @parent = @static_page
  end

  def create
    @new_page = StaticPage.new(static_page_params.merge(parent_id: @static_page.try(:id)))
    @parent ||= @static_page

    if @new_page.save
      @messages << "Successfully added static page."
      redirect_to static_page_path(parents: @parents.map(&:url), url: @new_page.url)
    else
      @messages << (["Validation failed:"] + @new_page.errors.full_messages).join('<br/>').html_safe
      render :new
    end
  end

  def edit
  end

  def update
    url = @static_page.url

    if @static_page.update_attributes(static_page_params)
      flash[:notice] = "Successfully updated static page."
      @parents ||= []
      redirect_to static_page_path(parents: @parents.map(&:url), url: @static_page.url)
    else
      flash[:notice] = "Validation error"
      render :edit
    end
  end

private
  def static_page_params
    params.require(:static_page).permit(:content, :title, :url)
  end

  def find_static_page
    @parents = []
    if params[:parents]
      # Make an array of parent page urls
      parent_urls = params[:parents].split('/')
      parent_urls.each do |purl|
        if @parents.present?
          @parents.append(@parents.last.children.find_by_url!(purl))
        else
          @parents.append(StaticPage.root_pages.find_by_url!(purl))
        end
      end
      @parent = @parents[-1]

      @static_page = @parent.children.find_by_url!(params[:url])
    elsif params[:url]
      @link = Shortlink.find_by_in_url(params[:url])
      @static_page = StaticPage.root_pages.find_by_url!(params[:url]) if not @link
    end
  end

  def authorize_static_pages
    authorize(['officers', 'serv'])
  end
end
