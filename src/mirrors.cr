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
json = Mirrors::LevelReader.parse("resources/level1.json")
level = Mirrors::LevelDisplay.new(json)

test.display = level
test.show
