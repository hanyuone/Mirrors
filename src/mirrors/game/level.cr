require "./grid.cr"
require "../alias.cr"
require "../items/*"

module Mirrors
  class Level
    getter lights : Array(Light)
    getter inventory : Array(Item)
    getter grids  : Array(Array(Grid?))

    getter dimensions : Dimensions

    getter success : Bool? = nil

    def initialize(@lights, @inventory, @grids)
      raise "Nothing in grids" if @grids.size.zero?
      @dimensions = {@grids[0].size, @grids.size}
    end

    private def out_of_bounds?(coords : Coords?) : Bool
      return if coords.nil?
      return !(0 <= coords[0] < @dimensions[0] && 0 <= coords[1] < @dimensions[1])
    end

    private def get_special(coords : LevelCoords) : Bool
      return @grids[coords[0]][coords[1]].specials_grid[coords[2]]
    end

    private def lights_fail? : Bool
      @lights.each do |light|
        return false if light.dir && !out_of_bounds?(light.coords)
      end

      return true
    end

    private def all_tiles_lit? : Bool
      @grids.each do |grid|
        tiles_state = @tile_grid
          .flatten
          .compact
          .reduce { |a, b| a && b }
        
        return false unless tiles_state
      end

      return true
    end

    private def can_exit?(light : Light) : Bool
      current_grid = @grids[light.coords[0]][light.coords[1]]
      
      return current_grid.exit_points[light.dir].contains?(case light.dir
        when Direction::Left, Direction::Right then light.coords[2] / 5
        when Direction::Up, Direction::Down then light.coords[2] % 5
      end)
    end

    private def move_new_grid(light : Light)
      light.coords = case light.dir
        when Direction::Left
          {light.coords[0] - 1, light.coords[1], light.coords[2] + 4}
        when Direction::Right
        when Direction::Up
        when Direction::Down
      end
    end

    # Move the light in a certain direction
    private def move_lights
      @lights.each do |light|
        x, y = light.coords[2] / 5, light.coords[2] % 5
        grid_coords = case light.dir
          when Direction::Left  then {x, y - 1}
          when Direction::Right then {x, y + 1}
          when Direction::Up    then {x - 1, y}
          when Direction::Down  then {x + 1, y}
          else {x, y}
        end

        if (0 <= grid_coords[0] < 5) && (0 <= grid_coords[1] < 5)
          light.coords = {light.coords[0], light.coords[1], grid_coords[0] * 5 + grid_coords[1]}
        elsif can_exit?(light)
          move_new_grid(light)
        else
          light.direction = nil
        end
      end
    end

    def toggle_switch(switch : Switch)
      return if switch.coords.nil?

      (0...switch.targets.size).each do |a|
        target = switch.targets[a]

        item_coords = target[0]
        @specials_grid[item_coords[0]][item_coords[1]] = target[1]
        switch.targets[a] = {target[0], target[2], target[1]}
      end
    end

    def place_item(inv_index : Int32, coords : LevelCoords)
      @inventory[inv_index].coords = coords
    end

    def lock_inventory
      @inventory.each do |item|
        @grids[item.coords[0]][item.coords[1]].specials_grid[item.coords[2]] = item if item.coords
      end
    end

    def tick
      light_tile
      
      # Checks if all the tiles have been lit, if they have
      # then the level is successfully complete
      @success = true if all_tiles_lit?

      @lights.each do |light|
        # Checks the item, to see if it's special or not
        case item = get_special(light.coords)
          when Teleporter
            if light.teleported
              light.teleported = false
            elsif (dest = item.dest) && get_special(dest).is_a?(Teleporter)
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
            toggle_switch(item)
        end
      end

      move_lights

      @success = false if lights_fail?
    end
  end
end