class EasterEggsController < ApplicationController
  # This will wrap a "pseudo-model", one that doesn't actually exist in the
  # database, but is completely based off of the user's session variables.

  def edit
  end

  def update
    ok = true

    ok &&= set_lang_prefs
    set_easter_flag :mirror, params[:mirror]
    puts params[:acid]
    set_easter_flag :acid, params[:acid]

    flash[:notice] = "Easter Egg settings updated." if ok
    redirect_to :action => :edit
  end

  def mirror
    set_easter_flag :mirror, true
    redirect_to request.referer || easter_eggs_edit_path
  end

  private

  def set_lang_prefs
    num_langs = 0
    langs = [:piglatin, :moonspeak]
    langs.each do |lang|
      if num_langs == 0
        set_easter_flag(lang, params[lang])
        num_langs += params[lang] ? 1 : 0
      else
        set_easter_flag(lang, nil)
        num_langs += 1 if params[lang]
      end
    end

    if num_langs < 2
      return true
    else
      flash[:notice] = "Only one language pack can be enabled at a time."
      return false
    end
  end

  # Sets session[flag] = value, or deletes it
  # @param flag [Symbol]
  # @param value [Boolean]
  def set_easter_flag(flag, value)
    if value
      session[flag] = true
    else
      session[flag] = nil
    end
  end

end
