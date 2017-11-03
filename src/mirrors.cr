# TODO:
# - Create basic game structure
#   - Mirrors
#   - Switches
#   - Teleporters
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

test = Mirrors::Window.new

grid = Mirrors::LevelReader.parse("resources/level1.json")
display = Mirrors::LevelDisplay.new(grid)

test.display = display
test.show
