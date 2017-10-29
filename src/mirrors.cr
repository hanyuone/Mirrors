# TODO:
# - Create basic game structure
#   - Mirrors
#   - Switches
#   - Teleporters
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

class TestDisplay < Mirrors::Display
  property :listener
  @listener : Mirrors::Listener?
  @texture : SF::RenderTexture

  @counter = 0

  private def add_items
    render = SF::RenderTexture.new(50, 50)
    rect = SF::RectangleShape.new({50, 50})
    rect.position = {0, 0}
    rect.fill_color = SF::Color::Red

    render.clear
    render.draw(rect)
    render.display

    sprite = Mirrors::Button.new(render.texture, ->() {
      puts @counter
      @counter += 1
      return
    })
    sprite.position = {10, 10}

    @listener.not_nil!.add_item(sprite, true)
  end

  def initialize
    super()

    @listener = Mirrors::Listener.new
    add_items
  end

  def draw_items
    square = SF::RectangleShape.new({100, 100})
    square.fill_color = SF::Color::White
    square.position = {200, 200}

    @texture.draw(square)
  end

  def draw : SF::Texture
    @texture.clear

    draw_items

    @listener.not_nil!.items.each do |item|
      @texture.draw(item)
    end

    @texture.display
    return @texture.texture
  end
end

test = Mirrors::Window.new

grid = Mirrors::LevelReader.parse("resources/level1.json")
display = Mirrors::LevelDisplay.new(grid)

test.display = display
test.show
