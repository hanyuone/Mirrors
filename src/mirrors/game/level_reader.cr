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
    private def self.to_coords(arr : JSONArray) : Coords
      return {arr[0].as(Int64).to_i32, arr[1].as(Int64).to_i32}
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
          switch_items = [] of Tuple(Coords, Special?, Special?)

          temp.each do |switch|
            coords = to_coords(switch["dest"].as(JSONArray))

            current_item = parse_item(switch["citem"].as(JSONHash)).as(Special?)
            next_item = parse_item(switch["nitem"].as(JSONHash)).as(Special?)

            switch_items.push({coords, current_item, next_item})
          end

          return Switch.new(switch_items)
      end
    end

    # Parses the given JSON file into a `Grid` (or game level),
    # given `filename` as an argument.
    def self.parse(filename : String) : Grid
      # Parse the JSON into `JSON::Any`, which can be manipulated
      # by Crystal
      level = JSON.parse(File.open(filename))

      # Get the width and the height of the board
      width = level["width"].as_i
      height = level["height"].as_i

      # Create the light
      light_coords = {
        level["start"]["coords"][0].as_i.to_i32,
        level["start"]["coords"][1].as_i.to_i32
      }
      light_dir = DIRECTIONS[level["start"]["dir"].as_s]

      light = Light.new(light_coords, light_dir)

      # Get the inventory - i.e. what tiles can be placed down
      inventory = level["inventory"].as_a.map(&.as(JSONHash))
      inventory = inventory.map { |a| {parse_item(a).not_nil!, {-1, -1}} }

      # Create the tile board for the grid (i.e. the board
      # containing the tiles which need to be lit up)
      tile_coords = level["tiles"].as_a.map { |a| to_coords(a.as(JSONArray)) }
      tile_arr = Array2D(Bool).new(width, height)

      tile_coords.each do |a|
        tile_arr.place_item(false, a)
      end

      # Create the items board for the grid (i.e. the board
      # containing the items which can manipulate the light
      # in various ways)
      items = level["items"].as_a
      item_arr = Array2D(Item).new(width, height)

      items.each do |temp|
        item = temp.as(JSONHash)
        item_coords = to_coords(item["coords"].as(JSONArray))
        item_arr.place_item(parse_item(item), item_coords)
      end

      return Grid.new(light, inventory, tile_arr.arr, item_arr.arr)
    end
  end
end