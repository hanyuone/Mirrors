# TODO:
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

Dir.cd(File.dirname(Process.executable_path.not_nil!))

# Mirrors::Game.new.run

pp Mirrors::LevelReader.parse("../resources/levels/new_level1.json")
