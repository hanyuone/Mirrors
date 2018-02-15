require "./grid.cr"
require "../alias.cr"
require "../items/*"

module Mirrors
  class Level
    getter lights    : Array(Light)
    getter inventory : Array(Light)
    getter grids     : Array(Array(Grid?))
    getter success   : Bool? = nil
    
    @teleported : Bool = false

    private def get_grid(coords : LevelCoords) : Grid?
      return @grids[coords[0]][coords[1]]
    end

    def initialize(@lights, @inventory, @grids); end

    private def move_new_grid(coords : LevelCoords, dir : Direction) : LevelCoords
      return case dir
        when Direction::Left  then {coords[0], coords[1] - 1, coords[2] + 20}
        when Direction::Right then {coords[0], coords[1] + 1, coords[2] - 20}
        when Direction::Up    then {coords[0] - 1, coords[1], coords[2] + 4}
        else {coords[0] + 1, coords[1], coords[2] - 4}
      end
    end

    private def move_light(light : Light)
      coords = light.coords
      dir = light.dir
      return if coords.nil? || dir.nil?

      x, y = coords[2] / 5, coords[2] % 5

      case dir
        when Direction::Left  then y -= 1
        when Direction::Right then y += 1
        when Direction::Up    then x -= 1
        else x += 1
      end

      light.coords = if (0 <= x < 5) && (0 <= y < 5)
        {coords[0], coords[1], x * 5 + y}
      else
        move_new_grid(coords, dir)
      end
    end

    private def light_tile(light : Light)
      coords = light.coords
      return if coords.nil?
      tile = get_grid(coords).not_nil!.tile_grid[coords[2]]

      @grids[coords[0]][coords[1]].not_nil!.tile_grid[coords[2]] = true unless tile.nil?
    end

    private def activate_item(light : Light)
      coords = light.coords
      return if coords.nil?
      special = get_grid(coords).not_nil!.item_grid[coords[2]]
      
      case special
        when Teleporter
          if @teleported
            @teleported = false
          else
            special.apply(light)
          end
        when Switch
          target = special.target
          special.active, special.passive = special.passive, special.active

          @grids[target[0]][target[1]].not_nil!.item_grid[target[2]] = special.active
        else
          special.apply(light) unless special.nil?
      end
    end

    def place_light(index : Int32, coords : LevelCoords, dir : Direction)
      @inventory[index].coords = coords
      @inventory[index].dir = dir
    end

    def place_inventory
      @lights += @inventory
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
