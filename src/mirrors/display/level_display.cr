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

    private def add_to_listener
      add_inventory
    end

    def initialize(@grid)
      super()
      @tile_size = calc_tile_size

      add_to_listener
    end

    def draw
      draw_listener
    end
  end
end