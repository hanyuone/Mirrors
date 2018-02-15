require "../alias.cr"
require "../items/*"

module Mirrors
  class Grid
    property tile_grid : Array(Bool?)
    property item_grid : Array(Item?)

    getter exit_points : Hash(Direction, Array(Int32))

    def initialize(@tile_grid, @item_grid, @exit_points); end
  end
end
