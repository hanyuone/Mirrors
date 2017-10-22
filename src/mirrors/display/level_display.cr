require "../grid.cr"

module Mirrors
  class LevelDisplay < Display
    @dimension : Int32
    @grid : Grid
    @texture : SF::RenderTexture

    private def calc_dimensions
      x_amount, y_amount = @grid.tile_grid[0].size, @grid.tile_grid.size
      width = 560 / x_amount
      height = 560 / y_amount

      @dimension = [width, height].min
    end

    def initialize(@grid)
      @dimension = 0
      @texture = SF::RenderTexture.new(800, 600)
      calc_dimensions
    end

    private def draw_tiles
      tiles = @grid.tile_grid

      (0...tiles.size).each do |x|
        (0...tiles[0].size).each do |y|
          square = SF::RectangleShape.new({@dimension, @dimension})
          square.position = {20 + (x * @dimension), 20 + (y * @dimension)}

          square.fill_color =
            case tiles[x][y]
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

    private def draw_special(x, y)
      special = @grid.specials_grid[x][y]

      font = SF::Font.from_file("resources/FiraCode.ttf")
      text = SF::Text.new(
        case special
          when LeftMirror then "/"
          when RightMirror then "\\"
          when Teleporter then "T"
          when Switch then "S"
          else ""
        end, font, 30
      )
      text.color = SF::Color::Black
      text.position = {20 + (x * @dimension), 20 + (y * @dimension)}

      @texture.draw(text)
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
    end

    def draw : SF::Texture
      draw_tiles
      draw_specials
      draw_inventory

      @texture.display

      return @texture.texture
    end
  end
end