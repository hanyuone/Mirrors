require "./direction.cr"

module Mirrors
  # Light - the main game mechanic in Mirrors.
  # It can move around depending on its surroundings.
  class Light
    property :dir, :coords, :teleported
    @coords : Tuple(Int32, Int32)
    @dir : Direction

    @teleported : Bool = false

    def initialize(@coords, @dir); end
  end
end
