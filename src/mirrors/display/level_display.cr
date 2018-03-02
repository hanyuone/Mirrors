require "../gui/*"
require "../game/*"
require "../items/*"
require "./tile_size.cr"

module Mirrors
  ARROW_KEYS = {
    SF::Keyboard::Key::Left => Direction::Left,
    SF::Keyboard::Key::Right => Direction::Right,
    SF::Keyboard::Key::Up => Direction::Up,
    SF::Keyboard::Key::Down => Direction::Down
  }

  class LevelDisplay < Display
    @level : Level
    @level_number : Int32
    @current_grid : Coords

    @event : SF::Event?

    @inventory = [] of Button

    @clock : SF::Clock

    private def current_grid : Grid?
      return @level.grids[@current_grid[0]][@current_grid[1]]
    end

    private def add_light_inventory
      @level.inventory.size.times do
        texture = SF::RenderTexture.new(100, 100)
        texture.clear(SF::Color::Transparent)

        circle_shape = SF::CircleShape.new(30)
        circle_shape.position = {20, 20}
        circle_shape.fill_color = SF::Color::White
        texture.draw(circle_shape)

        texture.display

        sprite = Button.new(texture.texture) {}
        sprite.position = {650, 50}

        @inventory.push(sprite)
        @listener.add_item(sprite)
      end
    end

    private def init_listener
      add_light_inventory
    end

    def initialize(@level_number)
      super()
      @level = LevelParser.parse("../resources/levels/#{@level_number}.json")
      @current_grid = {0, 0}
      @clock = SF::Clock.new

      init_listener
    end

    private def draw_grid
      new_grid = current_grid
      return if new_grid.nil?

      sprite = GridSprite.new(@level, {@current_grid[0], @current_grid[1]}).grid_sprite
      sprite.position = {50, 50}

      @texture.draw(sprite)
    end

    private def animate_grid(dir : Direction)
    end

    private def lock_inventory
      @inventory.each do |sprite|
        
      end
    end

    private def start
    end

    def draw
      draw_grid
      draw_listener

      lock_inventory

      if (event = @event).is_a?(SF::Event::KeyEvent) && ARROW_KEYS.key?(event.code)
        animate_grid(ARROW_KEYS[event.code])
      end
    end
  end
end