require "crsfml"
require "./helpers/display.cr"

module Mirrors
  class MenuDisplay < Display
    def initialize
      super
    end

    def draw
      draw_listener
    end

    def screen
      @texture.clear(SF::Color.new(0, 0, 0, 150))
      draw
      @texture.display
    end
  end
end