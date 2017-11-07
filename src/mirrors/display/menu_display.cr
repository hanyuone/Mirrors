require "./helpers/display.cr"

module Mirrors
  class MenuDisplay < Display
    @listener : Listener
    @texture : SF::RenderTexture

    def add_listener
    end

    def initialize
      super()
    end

    def draw
    end

    def screen
      @texture.clear(SF::Color.new(0, 0, 0, 150))
      draw
      @texture.display
    end
  end
end