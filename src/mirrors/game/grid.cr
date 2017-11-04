require "../items/*"

module Mirrors
  alias Item = Special | Switch

  class Grid
    getter :tile_grid, :specials_grid, :inventory
    
    @tile_grid : Array(Array(Bool?))
    @specials_grid : Array(Array(Item?))
    @inventory : Array(Tuple(Item, Tuple(Int32, Int32)))
    @light : Light

    def initialize(@light, @inventory, @tile_grid, @specials_grid); end

    # Move the light in a certain direction
    private def move_light
      @light.coords =
        case @light.dir
          when Direction::Left
            {@light.coords[0], @light.coords[1] - 1}
          when Direction::Right
            {@light.coords[0], @light.coords[1] + 1}
          when Direction::Up
            {@light.coords[0] - 1, @light.coords[1]}
          when Direction::Down
            {@light.coords[0] + 1, @light.coords[1]}
        end.not_nil!
    end

    private def light_tile
      # Lights up current tile
      current_tile = @tile_grid[@light.coords[0]][@light.coords[1]]
      @tile_grid[@light.coords[0]][@light.coords[1]] = true if current_tile == false

      pp @light.coords
      pp @tile_grid
    end

    # Calculates if a tile is out-of-bounds or not
    private def out_of_bounds?(coords : Coords) : Bool
      width = @tile_grid[0].size
      height = @tile_grid.size

      return !(0 <= coords[0] < width && 0 <= coords[1] < height)
    end

    # Place an item into the inventory
    def place_item(index : Int32, x : Int32, y : Int32)
      raise ArgumentError.new("Index out of bounds") if index >= @inventory.size
      @inventory[index] = {@inventory[index][0], {x, y}}
    end

    private def place_items
      @inventory.each do |tup|
        item = tup[0]
        pos = tup[1]

        @specials_grid[pos[0]][pos[1]] = item unless pos == {-1, -1}
      end
    end

    # The main simulator for Mirrors.
    def play
      place_items
      success = false
      pp @specials_grid

      loop do
        light_tile

        # Checks if all the tiles have been lit, if they have
        # then the level is successfully complete
        tile_state = @tile_grid
          .flatten
          .compact
          .reduce { |a, b| a && b }

        if tile_state
          success = true
          break
        end

        # Checks the item, to see if it's special or not
        case (item = @specials_grid[@light.coords[0]][@light.coords[1]])
          # When the item is a special item:
          when Special
            # Checks if the light has just been teleported, if it has
            # then we ignore the portal on that square, since we don't
            # want the light to bounce back and forth between portals
            if @light.teleported
              @light.teleported = false
            else
              item.apply(@light)
              next if item.is_a?(Teleporter)
            end
          # When the item is a switch:
          when Switch
            # Change the state of all items associated with the switch
            item.items.each do |a|
              item_coords = a[0]
              @specials_grid[item_coords[0]][item_coords[1]] = a[1]
              a = {a[0], a[2], a[1]}
            end
        end

        move_light

        if @light.dir == Direction::None || out_of_bounds?(@light.coords)
          break
        end
      end

      puts success
    end
  end
end
