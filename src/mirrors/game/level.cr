require "./grid.cr"
require "../alias.cr"
require "../items/*"

module Mirrors
  class Level
    getter lights    : Array(Light)
    getter inventory : Array(Tuple(LevelCoords, Direction)?)
    getter grids     : Array(Array(Grid?))
    
    @teleported : Bool = false

    private def get_grid(coords : LevelCoords) : Grid?
      return @grids[coords[0]][coords[1]]
    end

    def initialize(@lights, @inventory, @grids); end

    private def in_bounds?(coords : LevelCoords) : Bool
      return (0 <= coords[0] < @grids.size) && (0 <= coords[1] < @grids[0].size)
    end

    private def has_opening?(light : Light) : Bool
      coords = light.coords
      return false if coords.nil? || light.dir.nil?

      return case light.dir
        when Direction::Left, Direction::Right
          get_grid(coords).not_nil!.exit_points[light.dir].includes?(coords[2] / 5)
        else
          get_grid(coords).not_nil!.exit_points[light.dir].includes?(coords[2] % 5)
      end
    end

    private def move_new_grid(light : Light)
      return if light.dir.nil?
      
      coords = light.coords

      unless has_opening?(light)
        light.dir = nil
        return
      end

      new_coords = case light.dir
        when Direction::Left  then {coords[0], coords[1] - 1, coords[2] + 4}
        when Direction::Right then {coords[0], coords[1] + 1, coords[2] - 4}
        when Direction::Up    then {coords[0] - 1, coords[1], coords[2] + 20}
        else {coords[0] + 1, coords[1], coords[2] - 20}
      end

      if !in_bounds?(new_coords)
        light.dir = nil
      else
        light.coords = new_coords
      end
    end

    private def move_light(light : Light)
      dir = light.dir
      return if dir.nil?

      x, y = light.coords[2] / 5, light.coords[2] % 5

      case dir
        when Direction::Left  then y -= 1
        when Direction::Right then y += 1
        when Direction::Up    then x -= 1
        else x += 1
      end

      if (0 <= x < 5) && (0 <= y < 5)
        light.coords = {light.coords[0], light.coords[1], x * 5 + y}
      else
        move_new_grid(light)
      end
    end

    private def light_tile(light : Light)
      coords = light.coords
      tile = get_grid(coords).not_nil!.tile_grid[coords[2]]

      @grids[coords[0]][coords[1]].not_nil!.tile_grid[coords[2]] = true unless tile.nil?
    end

    private def activate_item(light : Light)
      case item = get_grid(light.coords).not_nil!.item_grid[light.coords[2]]
        when Teleporter
          if @teleported
            @teleported = false
          else
            special.apply(light)
            light_tile(light)
          end
        when Switch
          target = special.target
          special.active, special.passive = special.passive, special.active

          @grids[target[0]][target[1]].not_nil!.item_grid[target[2]] = special.active
        when Special
          special.apply(light)
      end
    end

    def place_light(index : Int32, coords : LevelCoords, dir : Direction)
      @inventory[index] = {coords, dir}
    end

    def place_inventory
      @inventory.each do |light|
        next if light.nil?
        new_light = Light.new(light[0], light[1])
        @lights.push(new_light)
      end
    end

    private def all_tiles_lit? : Bool
      width = @grids[0].size
      height = @grids.size
      total_grids = width * height

      (0...total_grids).each do |n|
        x, y = n / width, n % width

        if (grid = @grids[x][y])
          grid_tiles = grid.tile_grid
          grid_success = grid_tiles.reject(&.nil?).reduce { |a, b| a && b }

          return false unless grid_success
        end
      end

      return true
    end

    def success? : Bool?
      if all_tiles_lit?
        return true
      else
        @lights.each do |light|
          return nil unless light.dir.nil?
        end

        return false
      end
    end

    def turn
      raise "Cannot execute another turn." if success?

      @lights.each do |light|
        next if light.coords.nil?

        light_tile(light)
        activate_item(light)
        move_light(light)
      end
    end
  end
end
