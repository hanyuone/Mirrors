require "../gui/*"
require "../game/*"
require "../items/*"
require "./tile_size.cr"

module Mirrors
  class LevelDisplay < Display
    @level : Level
    @level_number : Int32
    @current_grid : Coords

    private def current_grid : Grid
      return @level[@current_grid[0]][@current_grid[1]]
    end

    private def add_light_button
    end

    private def init_listener
      add_light_button
    end

    def initialize(@level_number)
      super()
      @level = LevelReader.parse(@level_number)
      @current_grid = {@level.light.coords[0], @level.light.coords[1]}

      init_listener
    end

    private def draw_grid
      grid = GridSprite.new(current_grid)
      grid.position = {50, 50}

      @texture.draw(grid)
    end

    def draw
      draw_grid
    end
  end
end