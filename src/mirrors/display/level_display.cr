require "../gui/*"
require "../game/*"
require "../items/*"
require "./tile_size.cr"

module Mirrors
  class LevelDisplay < Display
    @level          : Level
    @level_number   : Int32
    @current_grid   : Tuple(Int32, Int32)
    
    @running : Bool

    @inv_sprites  : Array(HoverSprite) = [] of HoverSprite
    @timer        : SF::Clock
    @hover_sprite : SF::Sprite?

    # Decide the colour tile of a given item
    # TODO: Change this once proper textures for each of the
    #       items are created (way down the list)
    private def sprite_colour(item : Item?) : SF::Color
      color = case item
        when LeftMirror     then SF::Color::Red
        when RightMirror    then SF::Color::Blue
        when Teleporter     then SF::Color::Yellow
        when HorizontalOnly then SF::Color::Cyan
        when VerticalOnly   then SF::Color::Magenta
        when Switch         then SF::Color::Green
        else SF::Color::Transparent
      end
      
      color.a = 100
      return color
    end

    # TODO:
    # - Create a 1100x500 sprite, or 500x1100 sprite based on direction
    private def animate_grid(dir : Direction)
      case dir
        when Direction::Left
        when Direction::Right
        when Direction::Up
        when Direction::Down
      end
    end

    private def teleporter_on_hover(item : Teleporter)
      coords = item.coords
      dest = item.dest

      return if coords.nil? || dest.nil?

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

      @hover_sprite = cover_sprite
    end

    private def switch_on_hover(item : Switch)
      targets = item.targets

      cover = SF::RenderTexture.new(800, 600)
      cover.clear(SF::Color.new(0, 0, 0, 150))
      
      targets.each do |target|
        target_square = SF::RectangleShape.new({TILE_SIZE, TILE_SIZE})
        target_square.fill_color = decide_colour(target[1])
        target_square.position = {20 + (target[0][1] * TILE_SIZE), 80 + (target[0][0] * TILE_SIZE)}

        cover.draw(target_square)
      end

      cover.display

      cover_sprite = SF::Sprite.new(cover.texture)
      cover_sprite.position = {0, 0}

      @hover_sprite = cover_sprite
    end

    # Create a sprite based on the input of a given item,
    # includes creating listeners for teleporters and switches
    private def create_sprite(item : Item) : HoverSprite
      texture = SF::RenderTexture.new(TILE_SIZE, TILE_SIZE)
      texture.clear(SF::Color::Transparent)

      square = SF::RectangleShape.new({TILE_SIZE, TILE_SIZE})
      square.fill_color = sprite_colour(item)

      texture.draw(square)
      texture.display

      sprite = HoverSprite.new(texture.texture)
      sprite.position = {540, 40}

      case item
        when Teleporter
          sprite.on_hover { teleporter_on_hover(item.as(Teleporter)) }
          sprite.on_exit { @hover_sprite = nil }
        when Switch
          sprite = Button.new(texture.texture) { @level.toggle_switch(item.as(Switch)) }
          sprite.on_hover { switch_on_hover(item.as(Teleporter)) }

          sprite.on_exit { @hover_sprite = nil }
      end

      return sprite
    end

    # Add the inventory to @listener
    private def add_inventory
      @grid.inventory.each do |item|
        sprite = create_sprite(item)

        @inventory_sprites.push(sprite)
        @listener.add_item(sprite)
      end
    end

    # Generate the regular/hovered textures for the "Run" button, based on
    # a boolean
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

    def initialize(@level_number)
      super()
      @level = LevelReader.parse("../resources/levels/level#{@level_number}.json")
      @current_grid = {0, 0}

      @timer = SF::Clock.new

      add_to_listener
    end

    # A timer function to update the grid once every
    # 500 milliseconds (may or may not change)
    private def update_grid
      @level.tick
      @timer.restart
    end

    def draw
      draw_grid
      draw_listener

      if @running && @level.success.nil? && @timer.elapsed_time.as_milliseconds >= 500
        update_grid
      elsif !@running
        draw_light
      end

      if @level.success && @timer.elapsed_time.as_milliseconds >= 1000
        @inv_sprites = [] of HoverSprite
        @new_display = LevelDisplay.new(@level + 1)
        return
      end

      lock_inventory if @listener.has_reset

      if (sprite = @hover_sprite)
        @texture.draw(sprite)
      end
    end
  end
end