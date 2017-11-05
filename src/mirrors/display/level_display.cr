require "../game/grid.cr"
require "./helpers/display.cr"

module SF
  class Text
    def centre(position : Tuple(Int32, Int32), dimensions : Tuple(Int32, Int32))
      bounds = self.global_bounds

      centre = {position[0] + (dimensions[0] / 2), position[1] + (dimensions[1] / 2)}
      self.position = {centre[0] - (bounds.width / 2), centre[1] - (bounds.height / 2)}
    end
  end
end

module Mirrors
  class LevelDisplay < Display
    # Default items in Display superclass
    @listener : Listener
    @texture : SF::RenderTexture

    # The size of each individual tile on the grid
    @dimension : Int32
    # The game grid
    @grid : Grid

    # An array containing references to all of the sprites
    # inside of the grid
    @disp_inventory : Array(SF::Sprite)

    # Variables for the "delay" mechanic when the grid
    # "lights up": @running is a flag to check if the grid
    # has started to run, and @timer is to check if the
    # timespan for updating (currently 500ms) has passed
    @running : Bool
    @timer : SF::Clock

    # Calculates the dimensions of the tiles on the grid
    private def calc_dimensions
      x_amount, y_amount = @grid.tile_grid[0].size, @grid.tile_grid.size
      width = 560 / x_amount
      height = 560 / y_amount

      @dimension = [width, height].min
    end

    # Adds all of the tiles on the grid as sprites to the
    # event listener, as well as @disp_inventory to be used
    # for later
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

    # Adds the "menu" to the screen, currently only consists
    # of run button
    # TODO: Add an actual menu
    # FIXME: change the name of this function
    private def add_menu
      
      button_texture = SF::RenderTexture.new(100, 40)
      button_texture.clear(SF::Color::White)

      font = SF::Font.from_file("resources/FiraCode.ttf")
      button_text = SF::Text.new("Run", font)
      button_text.centre({1, 1}, {98, 38})
      puts button_text.position

      border_square = SF::RectangleShape.new({98, 38})
      border_square.fill_color = SF::Color::Black
      border_square.position = {1, 1}

      button_texture.draw(border_square)
      button_texture.draw(button_text)
      button_texture.display

      button = Button.new(button_texture.texture, ->() {
        @grid.place_items
        @running = true

        return
      })
      button.position = {650, 530}

      @listener.add_item(button, true)
    end

    # Calls all functions which add stuff to the event listener
    def add_listener
      add_inventory
      add_menu
    end

    # Initialize function
    def initialize(@grid)
      super()

      @dimension = calc_dimensions
      @disp_inventory = [] of SF::Sprite

      @running = false
      @timer = SF::Clock.new
      add_listener
    end

    # Draw a "tile" (something which is either lit or not)
    # onto the screen
    # FIXME: Rename all references of "tile" to something less
    # confusing, like "floor" or something
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
          SF::Color.new(50, 50, 50)
      end

      @texture.draw(square)
    end

    # Draws all the tiles in the grid
    private def draw_tiles
      tiles = @grid.tile_grid

      (0...tiles.size).each do |y|
        (0...tiles[0].size).each do |x|
          draw_tile(x, y)
        end
      end
    end

    # Decide on the colour of the special tile in
    # question
    # FIXME: Make this display images instead of colours
    private def decide_colour(item : Item) : SF::Color
      return case item
        when LeftMirror then SF::Color::Red
        when RightMirror then SF::Color::Blue
        when Teleporter then SF::Color::Yellow
        when Switch then SF::Color::Green
      end.not_nil!
    end

    # Draws a special tile onto the grid
    private def draw_special(x : Int32, y : Int32)
      special = @grid.specials_grid[x][y]
      return if special.nil?

      tile = SF::RectangleShape.new({50, 50})
      tile.position = {20 + (x * @dimension), 20 + (y * @dimension)}
      tile.fill_color = decide_colour(special)

      @texture.draw(tile)
    end

    # Super function to draw all of the special items
    private def draw_specials
      specials = @grid.specials_grid

      (0...specials.size).each do |y|
        (0...specials[0].size).each do |x|
          draw_special(x, y)
        end
      end
    end

    # "Latches" an item from the inventory onto a certain tile -
    # if an item being dragged is 25 pixels within a tile, it will
    # adjust to the coords of that tile.
    # FIXME: Noticed it does this for places that are outside of the
    # actual grid, fix that
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

    # A timer function to update the grid once every
    # 500 milliseconds (may or may not change)
    def update_grid
      @grid.tick
      @timer.restart
    end

    # Draw everything onto @texture
    def draw
      draw_tiles
      draw_specials

      @listener.items.each do |item|
        @texture.draw(item)
      end

      update_grid if @grid.success.nil? && @running && @timer.elapsed_time.as_milliseconds >= 500

      lock_inventory if @listener.has_reset
    end
  end
end
