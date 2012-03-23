class EasterEggsController < ApplicationController
  # This will wrap a "pseudo-model", one that doesn't actually exist in the
  # database, but is completely based off of the user's session variables.

  private
  # Metaprogramming method to add a generic flag enabler action
  # @param flag [Symbol] easter flag to be added to +@easter_eggs+
  # @param name [String,Symbol] action name (default: +flag+)
  def self.easter_enabler(flag, name=flag)
    define_method(flag) do
      set_easter_flag flag, true, true
    end
  end

  public

  def edit
  end

  def update
    ok = true

    ok &&= set_lang_prefs
    [ :mirror, :acid, :b ].each do |flag|
      set_easter_flag flag, params[flag]
    end

    flash[:notice] = "Easter Egg settings updated." if ok
    redirect_to :action => :edit
  end

  easter_enabler :mirror
  easter_enabler :b

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
  # @param redirect [Boolean] issue a redirect after setting flag?
  def set_easter_flag(flag, value, redirect=false)
    session[flag] = ( value ? true : nil )
    redirect_to(request.referer || easter_eggs_edit_path) if redirect
  end

end
