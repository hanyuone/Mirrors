require "../alias.cr"
require "../items/*"

module Mirrors
  class Grid
    getter tile_grid : Array(Array(Bool?))
    getter specials_grid : Array(Array(Item?))
    getter inventory : Array(Item)
    getter lights : Array(Light)

    @dimensions = Dimensions

    getter success : Bool?

    getter items_placed : Bool = false

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
        if (coords = light.coords)
          current_tile = @tile_grid[light.coords[0]][light.coords[1]]
          @tile_grid[light.coords[0]][light.coords[1]] = true if current_tile == false
        end
      end
    end

    # Calculates if a tile is out-of-bounds or not
    private def out_of_bounds?(coords : Coords) : Bool
      width = @tile_grid[0].size
      height = @tile_grid.size

      return !(0 <= coords[0] < width && 0 <= coords[1] < height)
    end

    # Place an item into the inventory
    def place_item(index : Int32, coords : Coords)
      @inventory[index].coords = coords
    end

    def place_items
      @inventory.each do |item|
        pos = item.coords
        @specials_grid[pos[0]][pos[1]] = item if pos
      end

      @items_placed = true
    end

    def toggle_switch(switch : Switch)
      return if switch.coords.nil?

      switch.targets.each do |target|
        item_coords = target[0]
        @specials_grid[item_coords[0]][item_coords[1]] = target[1]
        target = {target[0], target[2], target[1]}
      end
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
        item = @specials_grid[light.coords[0]][light.coords[1]]
        # Checks the item, to see if it's special or not
        case item
          when Teleporter
            if light.teleported
              light.teleported = false
            elsif (dest = item.dest) && @specials_grid[dest[0]][dest[1]].is_a?(Teleporter)
              item.apply(light)
              light_tile

              return
            end
          # When the item is a special item:
          when Special
            # Checks if the light has just been teleported, if it has
            # then we ignore the portal on that square, since we don't
            # want the light to bounce back and forth between portals
            item.apply(light)
          # When the item is a switch:
          when Switch
            # Change the state of all items associated with the switch
            item.targets.each do |target|
              item_coords = target[0]
              @specials_grid[item_coords[0]][item_coords[1]] = target[1]
              target = {target[0], target[2], target[1]}
            end
        end
      end

      move_lights

      @success = false if lights_fail?
    end
  end
end
