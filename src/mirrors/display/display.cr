require "./listener.cr"

module Mirrors
  abstract class Display
    property :listener
    @listener : Listener?
    @texture : SF::RenderTexture

    def initialize
      @texture = SF::RenderTexture.new(800, 600)
    end

    abstract def draw : SF::Texture
  end
end
