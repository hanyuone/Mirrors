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

  private def add_items
    render = SF::RenderTexture.new(50, 50)
    render.clear(SF::Color::White)
    render.display
    sprite = SF::Sprite.new(render.texture)
    sprite.position = {10, 10}

    @listener.not_nil!.add_item(sprite)
  end

  def initialize
    super()

    @listener = Mirrors::Listener.new
    add_items
  end

  def draw : SF::Texture
    @texture.clear

    @listener.not_nil!.items.each do |item|
      @texture.draw(item)
    end

    return @texture.texture
  end
end

test = Mirrors::Window.new
display = TestDisplay.new
test.display = display
test.show
