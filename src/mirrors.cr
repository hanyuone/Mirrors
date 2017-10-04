# TODO:
# - Create basic game structure
#   - Mirrors
#   - Switches
#   - Teleporters
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/*"

test = Mirrors::LevelReader.parse("resources/level.json")
test.play
