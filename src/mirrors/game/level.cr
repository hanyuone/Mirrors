require "./grid.cr"
require "../alias.cr"
require "../items/*"

module Mirrors
  class Level
    getter light     : Light
    getter inventory : Array(Item)
    getter grids     : Array(Array(Grid?))

    getter dimensions : Dimensions

    getter success : Bool? = nil

    def initialize(@lights, @inventory, @grids)
      raise "Nothing in grids" if @grids.size.zero?
      @dimensions = {@grids[0].size, @grids.size}
    end

    private def get_special(coords : LevelCoords) : Item?
      return @grids[coords[0]][coords[1]].special_grid[coords[2]]
    end

    private def set_special(coords : LevelCoords, item : Item)
      @grids[coords[0]][coords[1]].special_grid[coords[2]] = item
    end

    private def get_tile(coords : LevelCoords) : Bool?
      return @grids[coords[0]][coords[1]].tile_grid[coords[2]]
    end

    private def set_tile(coords : LevelCoords, bool : Bool)
      @grids[coords[0]][coords[1]].tile_grid[coords[2]] = bool
    end

    private def light_tile
      coords = @light.coords
      set_tile(coords, true) unless get_tile(coords).nil?
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

    private def light_new_grid
      @light.coords = case @light.dir
        when Direction::Left
          {@light.coords[0] - 1, @light.coords[1], @light.coords[2] + 4}
        when Direction::Right
          {@light.coords[0] + 1, @light.coords[1], @light.coords[2] - 4}
        when Direction::Up
          {@light.coords[0], @light.coords[1] - 1, @light.coords[2] + 20}
        when Direction::Down
          {@light.coords[0], @light.coords[1] + 1, @light.coords[2] - 20}
      end
    end

    private def light_can_exit? : Bool
      current_grid = @grids[@light.coords[0]][@light.coords[1]]
      
      return current_grid.exit_points[@light.dir].contains?(case @light.dir
        when Direction::Left, Direction::Right then @light.coords[2] / 5
        when Direction::Up, Direction::Down    then @light.coords[2] % 5
      end)
    end

    # Move the light in a certain direction
    private def move_light
      x, y = @light.coords[2] / 5, @light.coords[2] % 5
      grid_coords = case @light.dir
        when Direction::Left  then {x, y - 1}
        when Direction::Right then {x, y + 1}
        when Direction::Up    then {x - 1, y}
        when Direction::Down  then {x + 1, y}
        else {x, y}
      end

      if (0 <= grid_coords[0] < 5) && (0 <= grid_coords[1] < 5)
        @light.coords = {@light.coords[0], @light.coords[1], grid_coords[0] * 5 + grid_coords[1]}
      elsif light_can_exit?
        light_new_grid
      else
        @light.direction = nil
      end
    end

    def toggle_switch(switch : Switch)
      return if switch.coords.nil?
      
      set_special(switch.coords, switch.passive)
      switch.active, switch.passive = switch.passive, switch.active
    end

    def place_item(inv_index : Int32, coords : LevelCoords)
      @inventory[inv_index].coords = coords
    end

    def lock_inventory
      @inventory.each do |item|
        set_special(item.coords, item) if item.coords
      end
    end

    def tick
      light_tile
      
      # Checks if all the tiles have been lit, if they have
      # then the level is successfully complete
      @success = true if all_tiles_lit?

      # Checks the item, to see if it's special or not
      case item = get_special(@light.coords)
        when Teleporter
          if @light.teleported
            @light.teleported = false
          elsif (dest = item.dest) && get_special(dest).is_a?(Teleporter)
            item.apply(@light)
            light_tile
            return
          end
        # When the item is a special item other than a teleporter:
        when Special
          # Checks if the light has just been teleported, if it has
          # then we ignore the portal on that square, since we don't
          # want the light to bounce back and forth between portals
          item.apply(@light)
        # When the item is a switch:
        when Switch
          # Change the state of all items associated with the switch
          toggle_switch(item)
      end

      move_light

      @success = false if @light.dir.nil?
    end
  end
end