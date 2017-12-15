require "../alias.cr"
require "../items/*"

module Mirrors
  class Grid
    getter :tile_grid, :specials_grid, :inventory, :success, :items_placed
    
    @tile_grid : Array(Array(Bool?))
    @specials_grid : Array(Array(Item?))
    @inventory : Array(Tuple(Item, Coords))
    @lights : Array(Light)

    @dimensions = Dimensions

    @success : Bool?

    @items_placed : Bool = false

    def initialize(@lights, @inventory, @tile_grid, @specials_grid)
      @dimensions = {@tile_grid[0].size, @tile_grid.size}.as(Dimensions)
      @success = nil
    end

    def dimensions
      return @dimensions.as(Tuple(Int32, Int32))
    end

    # Move the light in a certain direction
    private def move_lights
      @lights.each do |light|
        light.coords = case light.dir
          when Direction::Left
            {light.coords[0], light.coords[1] - 1}
          when Direction::Right
            {light.coords[0], light.coords[1] + 1}
          when Direction::Up
            {light.coords[0] - 1, light.coords[1]}
          when Direction::Down
            {light.coords[0] + 1, light.coords[1]}
        end.not_nil!
      end
    end

    # Lights up current tile
    private def light_tile
      @lights.each do |light|
        current_tile = @tile_grid[light.coords[0]][light.coords[1]]
        @tile_grid[light.coords[0]][light.coords[1]] = true if current_tile == false
      end
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

    def place_items
      @inventory.each do |tup|
        item = tup[0]
        pos = tup[1]

        @specials_grid[pos[0]][pos[1]] = item unless pos == {-1, -1}
      end

      @items_placed = true
    end

    private def lights_fail? : Bool
      @lights.each do |light|
        return false if light.dir != Direction::None && !out_of_bounds?(light.coords)
      end

      return true
    end

    def tick
      light_tile
      
      # Checks if all the tiles have been lit, if they have
      # then the level is successfully complete
      tile_state = @tile_grid
        .flatten
        .compact
        .reduce { |a, b| a && b }

      @success = true if tile_state

      @lights.each do |light|
        # Checks the item, to see if it's special or not
        case (item = @specials_grid[light.coords[0]][light.coords[1]])
          # When the item is a special item:
          when Special
            # Checks if the light has just been teleported, if it has
            # then we ignore the portal on that square, since we don't
            # want the light to bounce back and forth between portals
            if item.is_a?(Teleporter) && light.teleported
              light.teleported = false
            else
              item.apply(light)

              if item.is_a?(Teleporter)
                light_tile

                return
              end
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
      end

      move_lights

      @success = false if lights_fail?
    end
  end
end
