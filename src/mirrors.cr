# TODO:
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/**"

font = SF::Font.from_file("resources/FiraCode.ttf")
text = SF::Text.new("0", font)
# text.character_size = 50

puts text.character_size
puts text.global_bounds.width

Mirrors::Game.new.run
