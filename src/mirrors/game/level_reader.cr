require "json"
require "../alias.cr"
require "../items/*"
require "./grid.cr"

module Mirrors
  DIRECTIONS = {
    "L" => Direction::Left,
    "R" => Direction::Right,
    "U" => Direction::Up,
    "D" => Direction::Down
  }

  # :nodoc:
  private class Array2D(T)
    getter :arr

    @width : Int32
    @height : Int32

    @arr : Array(Array(T?))

    private def init_grid
      temp = [] of Array(T?)

      (0...@width).each do |a|
        temp.push([] of T?)
        (0...@height).each do |b|
          temp[-1].push(nil)
        end
      end

      return temp
    end
    
    def initialize(@width, @height)
      @arr = init_grid
    end

    def place_item(item : T?, coords : Coords)
      @arr[coords[0]][coords[1]] = item
    end
  end

  # A class that reads levels in a JSON format, and
  # outputs a game grid.
  class LevelReader
    alias JSONArray = Array(JSON::Type)
    alias JSONHash = Hash(String, JSON::Type)

    # Converts an array containing two integers (as JSON::Type)
    # into a tuple, which the `Grid` class can use
    private def self.to_coords(arr : JSONArray) : LevelCoords
      new_arr = arr.map { |a| a.as(Int64).to_i32 }
      return Tuple(Int32, Int32, Int32).from(new_arr)
    end

    # Parses the JSON format of the item, turning it into
    # its respective object
    private def self.parse_item(item : JSONHash) : Item?
      item_type = item["type"].as(String)

      return case item_type
        when "N" then nil
        when "L" then LeftMirror.new
        when "R" then RightMirror.new
        when "H" then HorizontalOnly.new
        when "V" then VerticalOnly.new
        when "T"
          teleporter_dest = to_coords(item["dest"].as(JSONArray))
          
          Teleporter.new(teleporter_dest)
        when "S"
          temp = item["items"].as(JSONArray).map(&.as(JSONHash))
          switch_items = [] of Tuple(LevelCoords, Special?, Special?)

          temp.each do |switch|
            coords = to_coords(switch["dest"].as(JSONArray))

            current_item = parse_item(switch["citem"].as(JSONHash)).as(Special?)
            next_item = parse_item(switch["nitem"].as(JSONHash)).as(Special?)

            switch_items.push({coords, current_item, next_item})
          end

          Switch.new(switch_items)
      end
    end

    private def self.to_exits(exits : JSONHash) : Hash(Direction, Array(Int32))
      new_exits = {} of Direction => Array(Int32)

      exits.each do |key, value|
        new_exits[DIRECTIONS[key.as(String)]] = value.as(JSONArray).map { |a| a.as(Int64).to_i32 }
      end

      return new_exits
    end

    private def self.parse_grid(grid : JSONHash) : Tuple(Grid, Coords)
      coords = grid["coords"].as(JSONArray).map { |a| a.as(Int64).to_i32 }
      coords = Tuple(Int32, Int32).from(coords)

      # Create the tile board for the grid (i.e. the board
      # containing the tiles which need to be lit up)
      tiles = grid["tiles"].as(JSONArray).map { |a| a.as(Int64).to_i32 }
      tile_arr = [] of Bool?
      25.times { tile_arr.push(nil) }

      tiles.each { |a| tile_arr[a] = false }

      # Create the special items board for the grid (i.e. the board
      # containing the items which can manipulate the light
      # in various ways)
      specials = grid["specials"].as(JSONArray)
      specials_arr = [] of Item?
      25.times { specials_arr.push(nil) }

      specials.each do |temp|
        special = temp.as(JSONHash)
        special_coords = to_coords(special["coords"])

        if parsed_item = parse_item(special)
          parsed_item.coords = special_coords
          specials_arr[special_coords[2]] = parsed_item
        end
      end

      # Create a hash of exit points for the grid
      exit_points = to_exits(grid["exits"].as(JSONHash))

      return {Grid.new(tile_arr, specials_arr, exit_points), coords}
    end

    # Parses the given JSON file into a `Grid` (or game level),
    # given `filename` as an argument.
    def self.parse(filename : String) : Level
      # Parse the JSON into `JSON::Any`, which can be manipulated
      # by Crystal
      level = JSON.parse(File.open(filename))

      # Get the width and the height of the board
      dimensions = level["dimensions"].as_a.map { |a| a.as(Int64).to_i32 }
      dimensions = Tuple(Int32, Int32).from(dimensions)

      # Create an array of lights
      lights = [] of Light
      json_lights = level["lights"].as_a.map(&.as(JSONHash))

      # Create the light
      json_lights.each do |light|
        light_coords = to_coords(light["coords"].as(JSONArray))
        light_dir = DIRECTIONS[light["dir"].as(String)]

        lights.push(Light.new(light_coords, light_dir))
      end

      # Get the inventory - i.e. what tiles can be placed down
      inventory = level["inventory"].as_a.map(&.as(JSONHash))
      inventory = inventory.map { |a| parse_item(a).not_nil! }

      json_grids = level["grids"].as_a.map(&.as(JSONHash))
      grids = Array2D(Grid).new(dimensions[0], dimensions[1])

      json_grids.each do |temp|
        grid, coords = parse_grid(temp)
        grids.place_item(grid, coords)
      end

      return Level.new(lights, inventory, grids.arr)
    end
  end
end