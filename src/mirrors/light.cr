require "./direction.cr"

module Mirrors
  class Light
    property :dir, :coords, :teleported
    @coords : Coords
    @dir : Direction

    @teleported : Bool

    def initialize(@coords, @dir)
      @teleported = false
    end
  end
end