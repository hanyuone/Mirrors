require "../game/grid.cr"
require "./helpers/display.cr"

module Mirrors
  class LevelDisplay < Display
    @listener : Listener
    @texture : SF::RenderTexture

    @dimension : Int32
    @grid : Grid

    @disp_inventory : Array(SF::Sprite)

    private def calc_dimensions
      x_amount, y_amount = @grid.tile_grid[0].size, @grid.tile_grid.size
      width = 560 / x_amount
      height = 560 / y_amount

      @dimension = [width, height].min
    end

    private def add_inventory
      @dimension = calc_dimensions

      @grid.inventory.each do |tup|
        item = tup[0]

        texture = SF::RenderTexture.new(@dimension, @dimension)
        texture.clear
        
        square = SF::RectangleShape.new({@dimension, @dimension})
        square.fill_color = decide_colour(item)
        square.position = {0, 0}

        texture.draw(square)
        texture.display

        sprite = SF::Sprite.new(texture.texture)
        sprite.position = {620, 20}

        @disp_inventory.push(sprite)
        @listener.add_item(sprite)
      end
    end

    private def add_menu
      font = SF::Font.from_file("resources/FiraCode.ttf")
      button_text = SF::Text.new("Run", font)
      button_text.position = {0, 0}
      
      button_texture = SF::RenderTexture.new(100, 40)
      button_texture.clear
      button_texture.draw(button_text)
      button_texture.display

      button = Button.new(button_texture.texture, ->() {
        @grid.play        
      })
      button.position = {650, 530}

      @listener.add_item(button, true)
    end

    def add_listener
      add_inventory
      add_menu
    end

    def initialize(@grid)
      super()

      @dimension = calc_dimensions
      @disp_inventory = [] of SF::Sprite
      add_listener
    end

    private def draw_tile(x : Int32, y : Int32)
      tiles = @grid.tile_grid

      square = SF::RectangleShape.new({@dimension, @dimension})
      square.position = {20 + (x * @dimension), 20 + (y * @dimension)}

      square.fill_color = case tiles[x][y]
        when false
          SF::Color.new(150, 150, 150)
        when true
          SF::Color::White
        else
          SF::Color::Transparent
      end

      @texture.draw(square)
    end

    private def draw_tiles
      tiles = @grid.tile_grid

      (0...tiles.size).each do |x|
        (0...tiles[0].size).each do |y|
          draw_tile(x, y)
        end
      end
    end

    private def decide_colour(item : Item) : SF::Color
      return case item
        when LeftMirror then SF::Color::Red
        when RightMirror then SF::Color::Blue
        when Teleporter then SF::Color::Yellow
        when Switch then SF::Color::Green
      end.not_nil!
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

    private def lock_inventory
      (0...@disp_inventory.size).each do |a|
        sprite = @disp_inventory[a]
        item = @grid.inventory[a]

        pos = sprite.position
        close_test = {
          (pos[0] + @dimension - 20) % @dimension,
          (pos[1] + @dimension - 20) % @dimension
        }

        if ((close_test[0] < 25) || (close_test[0] > @dimension - 25)) && ((close_test[1] < 25) || (close_test[1] > @dimension - 25))
          grid_coord = {
            ((pos[0] - 20.0) / @dimension).round.to_i32,
            ((pos[1] - 20.0) / @dimension).round.to_i32
          }
          sprite.position = {
            (grid_coord[0] * @dimension) + 20,
            (grid_coord[1] * @dimension) + 20
          }
          @grid.place_item(a, grid_coord[0], grid_coord[1])
        end
      end
    end

    def draw
      draw_tiles
      draw_specials

      @listener.items.each do |item|
        @texture.draw(item)
      end

      lock_inventory if @listener.has_reset
    end
  end
end
