# TODO:
# - Create basic game structure
#   - Mirrors
#   - Switches
#   - Teleporters
# - Create GUI
#   - Config CrSFML
#   - Create basic GUI

require "./mirrors/*"

test = Mirrors::Grid.new([
  ([] of Bool?).concat([false, nil, false, false]),
  ([] of Bool?).concat([false, nil, false, false]),
  ([] of Bool?).concat([false, nil, false, false])
], [
  ([] of Mirrors::Item?).concat([Mirrors::Teleporter.new({2, 2}), nil, Mirrors::LeftMirror.new, Mirrors::RightMirror.new]),
  ([] of Mirrors::Item?).concat([Mirrors::Switch.new([
    { {2, 2}.as(Mirrors::Coords), Mirrors::Teleporter.new({0, 0}).as(Mirrors::Special?), nil.as(Mirrors::Special?) }
  ]), nil, nil, nil]),
  ([] of Mirrors::Item?).concat([nil, nil, nil, nil])
])

test.play
