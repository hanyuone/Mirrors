require "./helpers/*"
require "../game/*"
require "../items/*"

module Mirrors
  class LevelDisplay < Display
    @grid : Grid

    @tile_size : Int32

    private def calc_tile_size
      width = 500 / @grid.dimensions[0]
      height = 500 / @grid.dimensions[0]

      return [width, height].min
    end

    private def decide_colour(item : Item) : SF::Color
      color = case item
        when LeftMirror then SF::Color::Red
        when RightMirror then SF::Color::Blue
        when Teleporter then SF::Color::Yellow
        when HorizontalOnly then SF::Color::Cyan
        when VerticalOnly then SF::Color::Magenta
        when Switch then SF::Color::Green
      end.not_nil!
      
      color.a = 100
      return color
    end

    private def create_sprite(item : Item) : HoverSprite
      texture = SF::RenderTexture.new(@tile_size, @tile_size)
      texture.clear(SF::Color::Transparent)

      square = SF::RectangleShape.new({@tile_size, @tile_size})
      square.fill_color = decide_colour(item)

      texture.draw(square)
      texture.display

      sprite = HoverSprite.new(texture.texture)
      sprite.position = {540, 40}

      return sprite
    end

    private def add_inventory
      @grid.inventory.each do |tup|
        @listener.add_item(create_sprite(tup[0]))
      end
    end

    # Adds the "menu" to the screen, currently only consists
    # of run button
    # TODO: Add an actual menu
    # FIXME: change the name of this function
    private def add_menu
      button_texture = SF::RenderTexture.new(100, 40)
      button_texture.clear(SF::Color::White)

      font = SF::Font.from_file("../resources/FiraCode.ttf")
      button_text = SF::Text.new("Run", font)
      button_text.fill_color = SF::Color.new(100, 100, 100)
      button_text.centre({50, 20})

      border_square = SF::RectangleShape.new({98, 38})
      border_square.fill_color = SF::Color::Black
      border_square.position = {1, 1}

      button_texture.draw(border_square)
      button_texture.draw(button_text)
      button_texture.display

      hover_texture = SF::RenderTexture.new(100, 40)
      hover_texture.clear(SF::Color::White)

      hover_text = SF::Text.new("Run", font)
      hover_text.fill_color = SF::Color::White
      hover_text.centre({50, 20})

      hover_texture.draw(border_square)
      hover_texture.draw(hover_text)
      hover_texture.display

      button = Button.new(button_texture.texture, hover_texture.texture) do
        @grid.place_items
        @running = true
      end

      button.position = {600, 530}

      @listener.add_item(button, true)
    end

    private def add_to_listener
      add_inventory
      add_menu
    end

    def initialize(@grid)
      super()
      @tile_size = calc_tile_size

      add_to_listener
    end

    private def draw_tile(x : Int32, y : Int32)
      tiles = @grid.tile_grid

      square = SF::RectangleShape.new({@tile_size, @tile_size})
      square.position = {20 + (x * @tile_size), 80 + (y * @tile_size)}

      square.fill_color = case tiles[x][y]
        when false
          SF::Color.new(150, 150, 150)
        when true
          SF::Color::White
        else
          SF::Color.new(50, 50, 50)
      end

      @texture.draw(square)
    end

    # Draws all the tiles in the grid
    private def draw_tiles
      tiles = @grid.tile_grid

      (0...@grid.dimensions[0]).each do |y|
        (0...@grid.dimensions[1]).each do |x|
          draw_tile(x, y)
        end
      end
    end

    def draw
      draw_tiles
      draw_listener
    end
  end
end