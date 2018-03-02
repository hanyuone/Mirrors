require "crsfml"

require "./listener.cr"

module Mirrors
  abstract class Display
    property listener : Listener
    getter texture : SF::RenderTexture
    getter new_display : Display?

    property event : SF::Event? = nil

    def initialize
      @listener = Listener.new
      @texture = SF::RenderTexture.new(800, 600)
    end

    def draw_listener
      unless @listener.items.size.zero?
        @listener.items.map { |tup| tup[0] }.each do |item|
          @texture.draw(item)
        end
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
