require "./direction.cr"

module Mirrors
  # Light - the main game mechanic in Mirrors.
  # It can move around depending on its surroundings.
  class Light
    property coords : LevelCoords
    property dir : Direction?

    property teleported : Bool = false

    def initialize(@coords, @dir); end
  end
end

