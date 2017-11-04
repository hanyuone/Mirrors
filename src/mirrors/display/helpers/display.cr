require "./listener.cr"

module Mirrors
  abstract class Display
    getter :listener
    @listener : Listener
    @texture : SF::RenderTexture

    def initialize
      @listener = Listener.new
      @texture = SF::RenderTexture.new(800, 600)
    end

    abstract def draw

    def screen : SF::Texture
      @texture.clear
      draw
      @texture.display

      return @texture.texture
    end
  end
end
