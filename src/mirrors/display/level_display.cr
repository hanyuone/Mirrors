require "../grid.cr"
require "./display.cr"

module Mirrors
  class LevelDisplay < Display
    @listener : Listener?
    @texture : SF::RenderTexture

    @dimension : Int32
    @grid : Grid

    private def calc_dimensions
      x_amount, y_amount = @grid.tile_grid[0].size, @grid.tile_grid.size
      width = 560 / x_amount
      height = 560 / y_amount

      @dimension = [width, height].min
    end

    def initialize(@grid)
      super()

      @listener = Listener.new
      @dimension = 0
      calc_dimensions
    end

    private def draw_tiles
      tiles = @grid.tile_grid

      (0...tiles.size).each do |x|
        (0...tiles[0].size).each do |y|
          square = SF::RectangleShape.new({@dimension, @dimension})
          square.position = {20 + (x * @dimension), 20 + (y * @dimension)}

          square.fill_color = case tiles[x][y]
            when true
              SF::Color.new(200, 200, 200)
            when false
              SF::Color::White
            else
              SF::Color::Transparent
          end

          @texture.draw(square)
        end
      end
    end

    private def decide_colour(item : Item) : SF::Color
      return case item
        when LeftMirror then SF::Color::Red
        when RightMirror then SF::Color::Blue
        when Teleporter then SF::Color::Yellow
        when Switch then SF::Color::Green
        else SF::Color::Transparent
      end
    end

    private def draw_special(x : Int32, y : Int32)
      special = @grid.specials_grid[x][y]
      return if special.nil?

      tile = SF::RectangleShape.new({50, 50})
      tile.position = {20 + (x * @dimension), 20 + (y * @dimension)}
      tile.fill_color = decide_colour(special)

      @texture.draw(tile)
    end

    private def draw_specials
      specials = @grid.specials_grid

      (0...specials.size).each do |x|
        (0...specials[0].size).each do |y|
          draw_special(x, y)
        end
      end
    end

    private def draw_inventory
      inventory = @grid.inventory

      inventory.each do |item|
        texture = SF::RenderTexture.new
        texture.clear(decide_colour(item))

        sprite = SF::Sprite.new(texture.texture)
        sprite.position = {620, 20}

        @listener.try(&.add_item(sprite))
      end
    end

    private def draw_menu
    end

    def draw : SF::Texture
      draw_tiles
      draw_specials
      draw_inventory
      draw_menu

      # @listener.try(&.draggables).each do |sprite|
      #   @texture.draw(sprite)
      # end

      # @listener.try(&.buttons).each do |button|
      #   @texture.draw(button.sprite)
      # end

      @texture.display

      return @texture.texture
    end
  end
end