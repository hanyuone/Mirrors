require "crsfml"
require "./helpers/display.cr"

module Mirrors
  class StartDisplay < Display
    @listener : Listener
    @texture : SF::RenderTexture

    def add_start_buttons
    end

    def initialize
      super

      add_start_buttons
    end

    def draw
      super
    end
  end
end