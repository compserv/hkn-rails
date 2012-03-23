module EasterEggsHelper

  # Renders checkbox and label for an easter egg.
  # @param key [Symbol] +@easter_eggs+ key, like +:mirror+ or +:acid+
  # @param name [String]
  def easter_egg(key, name)
    [
      check_box_tag(key, true, @easter_eggs[key]),
      label_tag(key, name),
      '<br/>'
    ].join.html_safe
  end

  # Renders checkbox and easter egg only if it's currently enabled.
  # @param key [Symbol] +@easter_eggs+ key, like +:mirror+ or +:acid+
  # @param name [String]
  def hidden_easter_egg(key, name)
    easter_egg(key, name) if @easter_eggs[key]
  end
end
