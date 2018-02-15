# TODO:
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

Dir.cd(File.dirname(Process.executable_path.not_nil!))

# Mirrors::Game.new.run

level = Mirrors::LevelParser.parse("../resources/levels/0.json")
level.place_light(0, {0, 0, 17}, Mirrors::Direction::Up)
level.place_inventory

while level.success?.nil?
  pp level.grids[0][0]
  level.turn
end
