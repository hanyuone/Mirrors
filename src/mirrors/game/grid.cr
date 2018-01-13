require "../alias.cr"
require "../items/*"

module Mirrors
  class Grid
    getter tile_grid    : Array(Bool?)
    getter special_grid : Array(Item?)

    getter exit_points  : Hash(Direction, Array(Int32))

    def initialize(@tile_grid, @special_grid, @exit_points); end
  end
end
