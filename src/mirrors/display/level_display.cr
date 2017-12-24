require "../gui/*"
require "../game/*"
require "../items/*"

module Mirrors
  class LevelDisplay < Display
    @level : Int32

    @grid : Grid
    @tile_size : Int32

    @inventory_sprites : Array(HoverSprite) = [] of HoverSprite

    @timer : SF::Clock

    @on_hover_sprite : SF::Sprite?

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

      case item
        when Teleporter
          sprite.on_hover do
            tp_coords = item.as(Teleporter).coords
            tp_dest = item.as(Teleporter).dest

            if (coords = tp_coords) && (dest = tp_dest)
              cover = SF::RenderTexture.new(800, 600)
              cover.clear(SF::Color.new(0, 0, 0, 150))

              coords_square = SF::RectangleShape.new({@tile_size, @tile_size})
              coords_square.fill_color = SF::Color::Yellow
              coords_square.position = {20 + (coords[1] * @tile_size), 80 + (coords[0] * @tile_size)}

              dest_square = SF::RectangleShape.new({@tile_size, @tile_size})
              dest_square.fill_color = SF::Color::Yellow
              dest_square.position = {20 + (dest[1] * @tile_size), 80 + (dest[0] * @tile_size)}

              cover.draw(coords_square)
              cover.draw(dest_square)
              cover.display

              cover_sprite = SF::Sprite.new(cover.texture)
              cover_sprite.position = {0, 0}

              @on_hover_sprite = cover_sprite
            end
          end

          sprite.on_exit do
            @on_hover_sprite = nil
          end
      end

      return sprite
    end

    private def add_inventory
      @grid.inventory.each do |tup|
        sprite = create_sprite(tup[0])

        @inventory_sprites.push(sprite)
        @listener.add_item(sprite)
      end
    end

    private def gen_run_button(hover : Bool) : SF::Texture
      texture = SF::RenderTexture.new(100, 40)
      texture.clear(SF::Color::White)

      font = SF::Font.from_file("../resources/FiraCode.ttf")
      text = SF::Text.new("Run", font)
      text.fill_color = hover ? SF::Color::White : SF::Color.new(100, 100, 100)
      text.centre({50, 20})

      border = SF::RectangleShape.new({98, 38})
      border.fill_color = SF::Color::Black
      border.position = {1, 1}

      texture.draw(border)
      texture.draw(text)
      texture.display

      return texture.texture
    end

    # Adds the "menu" to the screen, currently only consists
    # of run button
    # TODO: Add an actual menu
    # FIXME: change the name of this function
    private def add_run_button
      button = Button.new(gen_run_button(false), gen_run_button(true)) do
        @grid.place_items
        @running = true
      end

      button.position = {600, 530}

      @listener.add_item(button, true)
    end

    private def add_to_listener
      add_inventory
      add_run_button
    end

    def initialize(@level : Int32)
      super()
      @grid = LevelReader.parse("../resources/level#{level}.json")

      @timer = SF::Clock.new
      @tile_size = calc_tile_size

      add_to_listener
    end

    # Draws a special tile onto the grid
    private def draw_special(x : Int32, y : Int32)
      special = @grid.specials_grid[x][y]
      return if special.nil?

      tile = SF::RectangleShape.new({@tile_size, @tile_size})
      tile.position = {20 + (y * @tile_size), 80 + (x * @tile_size)}
      tile.fill_color = decide_colour(special)

      @texture.draw(tile)
    end

    # Super function to draw all of the special items
    private def draw_specials
      specials = @grid.specials_grid

      (0...@grid.dimensions[0]).each do |x|
        (0...@grid.dimensions[1]).each do |y|
          draw_special(x, y)
        end
      end
    end

    private def draw_tile(x : Int32, y : Int32)
      tiles = @grid.tile_grid

      square = SF::RectangleShape.new({@tile_size, @tile_size})
      square.position = {20 + (y * @tile_size), 80 + (x * @tile_size)}

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

      (0...@grid.dimensions[0]).each do |x|
        (0...@grid.dimensions[1]).each do |y|
          draw_tile(x, y)
        end
      end
    end

    # "Latches" an item from the inventory onto a certain tile -
    # if an item being dragged is 25 pixels within a tile, it will
    # adjust to the coords of that tile.
    private def lock_inventory
      (0...@inventory_sprites.size).each do |a|
        sprite = @inventory_sprites[a]
        item = @grid.inventory[a]

        pos = sprite.position

        position_test = {
          (pos[0] + @tile_size - 20) % @tile_size,
          (pos[1] + @tile_size - 80) % @tile_size
        }

        if (25 < position_test[0] < @tile_size - 25) ||
          (25 < position_test[1] < @tile_size - 25)
          sprite.position = {540, 40}
          next
        end

        tile_coords = {
          (pos[0] / @tile_size).round.to_i32,
          (pos[1] / @tile_size).round.to_i32
        }

        if (0 <= tile_coords[0] < @grid.dimensions[0]) &&
          (0 <= tile_coords[1] < @grid.dimensions[1])
          @grid.place_item(a, tile_coords[1], tile_coords[0])
          sprite.position = {
            (tile_coords[0] * @tile_size) + 20,
            (tile_coords[1] * @tile_size) + 80
          }
        else
          @grid.place_item(a, -1, -1)
          sprite.position = {540, 40}
        end
      end
    end

    # A timer function to update the grid once every
    # 500 milliseconds (may or may not change)
    def update_grid
      @grid.tick
      @timer.restart
    end

    def check_success
      @new_display = LevelDisplay.new(@level + 1) if @grid.success == true &&
        @timer.elapsed_time.as_milliseconds >= 1000
    end

    def draw
      draw_tiles
      draw_specials
      draw_listener

      update_grid if @grid.success.nil? &&
        @running &&
        @timer.elapsed_time.as_milliseconds >= 500

      check_success

      lock_inventory if @listener.has_reset

      @texture.draw(@on_hover_sprite.not_nil!) unless @on_hover_sprite.nil?
    end
  end
end