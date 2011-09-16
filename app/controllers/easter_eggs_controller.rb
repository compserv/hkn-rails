class EasterEggsController < ApplicationController
  # This will wrap a "pseudo-model", one that doesn't actually exist in the
  # database, but is completely based off of the user's session variables.

  def edit
  end

  def update
    puts params.to_json
    num_langs = 0
    langs = [:piglatin, :moonspeak]
    langs.each do |lang|
      if num_langs == 0
        session[lang] = params[lang]
        num_langs += params[lang] ? 1 : 0
      else
        session[lang] = nil
        num_langs += 1 if params[lang]
      end
    end

    if num_langs < 2
      flash[:notice] = "Easter Egg settings updated."
    else
      flash[:notice] = "Only one language pack can be enabled at a time."
    end
    redirect_to :action => :edit
  end

end
