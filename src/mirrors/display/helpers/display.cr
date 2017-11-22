require "crsfml"
require "./listener.cr"

module Mirrors
  # An abstract parent class, for which all display "screens"
  # extend
  abstract class Display
    getter :listener, :new_display
    # Each display has both `@listener` and `@texture`, which are
    # the event listener and the actual "screen" onto which everything
    # is drawn respectively
    @listener : Listener
    @texture : SF::RenderTexture

    @new_display : Display?

    # Initialise function
    def initialize
      @listener = Listener.new
      @texture = SF::RenderTexture.new(800, 600)
    end

    def draw_listener
      @listener.items.each do |item|
        @texture.draw(item)
      end
    end

    # Draws everything to @texture - sprites, buttons, rectangles,
    # everything.
    abstract def draw

    # Gets the actual screen of @texture.
    def screen : SF::Sprite
      @texture.clear
      draw
      @texture.display

      sprite = SF::Sprite.new(@texture.texture)
      sprite.position = {0, 0}

      return sprite
    end
  end
end
