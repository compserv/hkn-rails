class PagesController < ApplicationController
  layout "static"

  def show
    render template: "pages/#{page}"
  end

  private

  def page
    params.require(:page)
  end
end
