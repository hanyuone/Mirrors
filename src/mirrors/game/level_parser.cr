require "json"
require "../alias.cr"
require "../items/*"
require "./grid.cr"

module Mirrors
  alias JSONArray = Array(JSON::Type)
  alias JSONHash  = Hash(String, JSON::Type)

  DIRECTIONS = {
    "L" => Direction::Left,
    "R" => Direction::Right,
    "U" => Direction::Up,
    "D" => Direction::Down
  }
  class LevelParser
    private def self.to_coords(coords : JSONArray) : Coords
      coords = coords.map(&.as(Int64).to_i32)
      return Coords.from(coords)
    end

    private def self.to_level_coords(coords : JSONArray) : LevelCoords
      coords = coords.map(&.as(Int64).to_i32)
      return LevelCoords.from(coords)
    end

    private def self.parse_item(hash : JSONHash) : Tuple(Item?, Int32)
      return {case hash["type"]
        when "L" then LeftMirror.new
        when "R" then RightMirror.new
        when "H" then HorizontalOnly.new
        when "V" then VerticalOnly.new
        when "B" then Block.new
        when "T"
          dest = to_level_coords(hash["dest"].as(JSONArray))
          Teleporter.new(dest)
        when "S"
          target = to_level_coords(hash["target"].as(JSONArray))
          active = parse_item(hash["active"].as(JSONHash))[0]
          passive = parse_item(hash["passive"].as(JSONHash))[0]

          Switch.new(target, active, passive)
        else nil
      end, hash["coords"].as(Int64).to_i32}
    end

    private def self.to_exit_points(hash : JSONHash) : Hash(Direction, Array(Int32))
      exit_points = {} of Direction => Array(Int32)

      hash.each do |key, value|
        exit_points[DIRECTIONS[key]] = value.as(JSONArray).map(&.as(Int64).to_i32)
      end

      return exit_points
    end

    private def self.parse_grid(hash : JSONHash) : Tuple(Grid, Coords)
      coords = to_coords(hash["coords"].as(JSONArray))

      tiles_json = hash["tiles"].as(JSONArray).map(&.as(Int64).to_i32)
      tiles = [] of Bool?
      25.times { tiles.push(nil) }
      tiles_json.each do |tile|
        tiles[tile] = false
      end

      items_json = hash["items"].as(JSONArray).map { |item| parse_item(item.as(JSONHash)) }
      items = [] of Item?
      25.times { items.push(nil) }
      items_json.each do |item, coords|
        items[coords] = item
      end

      exit_points = to_exit_points(hash["exits"].as(JSONHash))

      return {Grid.new(tiles, items, exit_points), coords}
    end

    def self.parse(path : String) : Level
      json = JSON.parse(File.open(path))

      lights = [] of Light
      lights_json = json["lights"].as_a.map(&.as(JSONHash))

      lights_json.each do |light|
        coords = to_level_coords(light["coords"].as(JSONArray))
        dir = DIRECTIONS[light["dir"].as(String)]

        lights.push(Light.new(coords, dir))
      end

      inventory = [] of Light
      new_lights = json["new_lights"].as_i
      new_lights.times do
        inventory.push(Light.new(nil, nil))
      end

      dimensions = to_coords(json["dimensions"].as_a)
      grids = Array(Array(Grid?)).new(dimensions[1]) { Array(Grid?).new(dimensions[0]) { nil } }

      grids_json = json["grids"].as_a.map { |json| parse_grid(json.as(JSONHash)) }
      grids_json.each do |grid, coords|
        grids[coords[0]][coords[1]] = grid
      end

      return Level.new(lights, inventory, grids)
    end
  end
end
