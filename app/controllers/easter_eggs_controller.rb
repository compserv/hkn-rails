class EasterEggsController < ApplicationController
  # This will wrap a "pseudo-model", one that doesn't actually exist in the
  # database, but is completely based off of the user's session variables.

  def edit
  end

  def update
    @piglatin = session[:piglatin] = params[:piglatin]
    flash[:notice] = "Easter Egg settings updated."
    redirect_to :action => :edit
  end

end
