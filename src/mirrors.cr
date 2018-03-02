# TODO:
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

Dir.cd(File.dirname(Process.executable_path.not_nil!))

Mirrors::Game.new.run
