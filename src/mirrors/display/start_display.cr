require "./helpers/display.cr"

module Mirrors
  class StartDisplay < Display
    @listener : Listener
    @texture : SF::RenderTexture

    def initialize
      super()
    end

    def draw
    end
  end
end