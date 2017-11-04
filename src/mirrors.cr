# TODO:
# - Create basic game structure
#   - Mirrors
#   - Switches
#   - Teleporters
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

grid = Mirrors::LevelReader.parse("resources/level1.json")
display = Mirrors::LevelDisplay.new(grid)

test = Mirrors::Window.new(display)
test.show
