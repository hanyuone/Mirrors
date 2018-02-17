# TODO:
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

Dir.cd(File.dirname(Process.executable_path.not_nil!))

# Mirrors::Game.new.run

level = Mirrors::LevelParser.parse("../resources/levels/2.json")
level.place_light(0, {0, 0, 16}, Mirrors::Direction::Up)
level.place_inventory

while level.success?.nil?
  pp level.grids[0][0].not_nil!.tile_grid
  pp level.grids[0][1].not_nil!.tile_grid
  level.turn
end

puts level.success?
