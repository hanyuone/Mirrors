require "crsfml"
require "../game/grid.cr"
require "../game/level.cr"
require "./tile_size.cr"

module Mirrors
  # Sprite that displays an entire grid, in a 500x500 SF::Sprite.
  class GridSprite
    getter level  : Level
    getter coords : Coords

    getter texture = SF::RenderTexture.new(500, 500)

    private def grid
      return @level.grids[@coords[0]][@coords[1]].not_nil!
    end

    def initialize(@level, @coords); end

    private def draw_tiles
      tiles = grid.tile_grid

      (0...25).each do |n|
        x, y = n / 5, n % 5

        square = SF::RectangleShape.new({TILE_SIZE, TILE_SIZE})

        square.position = {y * TILE_SIZE, x * TILE_SIZE}
        square.fill_color = case tiles[n]
          when false then SF::Color.new(150, 150, 150)
          when true  then SF::Color::White
          else            SF::Color.new(50, 50, 50)
        end

        @texture.draw(square)
      end
    end

    private def decide_colour(item : Item) : SF::Color
      case item
        when LeftMirror     then SF::Color::Red
        when RightMirror    then SF::Color::Blue
        when Teleporter     then SF::Color::Yellow
        when Block          then SF::Color::Black
        when HorizontalOnly then SF::Color::Magenta
        when VerticalOnly   then SF::Color::Cyan
        else SF::Color::Green
      end
    end

    private def decide_sprite(item : Item) : SF::Sprite
    end

    # Super function to draw all of the special specials
    private def draw_items
      items = grid.item_grid

      (0...25).each do |n|
        x, y = n / 5, n % 5

        item = items[n]
        next if item.nil?

        tile = SF::RectangleShape.new({TILE_SIZE, TILE_SIZE})
        tile.position = {y * TILE_SIZE, x * TILE_SIZE}
        tile.fill_color = decide_colour(item)

        @texture.draw(tile)
      end
    end

    private def draw_lights
      @level.lights.each do |light|
        next if {light.coords[0], light.coords[1]} != coords
        x, y = light.coords[2] / 5, light.coords[2] % 5

        light_shape = SF::CircleShape.new(TILE_SIZE / 2)
        light_shape.position = {y * TILE_SIZE + (TILE_SIZE / 4), x * TILE_SIZE + (TILE_SIZE / 4)}
        light_shape.fill_color = SF::Color::White

        @texture.draw(light_shape)
      end
    end

    def grid_sprite : SF::Sprite
      @texture.clear

      draw_tiles
      draw_items
      draw_lights
      
      @texture.display

      return SF::Sprite.new(@texture.texture)
    end

    private def horizontal_connection(dir : Direction) : SF::Sprite
      connect_coords = grid.exits[dir]
      connect_texture = SF::RenderTexture.new(100, 500)

      (0...5).each do |n|
        rect = SF::RectangleShape.new({100, 100})
        rect.position = {0, n * 100}

        rect.fill_color = if connect_coords.contains?(n)
          SF::Color::White
        else
          SF::Color.new(150, 150, 150)
        end

        connect_texture.draw(rect)
      end

      return SF::Sprite.new(connect_texture.texture)
    end

    def horizontal_sprite(new_grid : Grid, dir : Direction) : SF::Sprite
      horizontal_texture = SF::RenderTexture.new(1100, 500)
      new_sprite = GridSprite.new(new_grid).grid_sprite
      connector = horizontal_connection(dir)
      cur_sprite = grid_sprite

      case dir
        when Direction::Left
          new_sprite.position = {0, 0}
          connector.position = {500, 0}
          cur_sprite.position = {600, 0}
        when Direction::Right
          new_sprite.position = {600, 0}
          connector.position = {500, 0}
          cur_sprite.position = {0, 0}
      end

      horizontal_texture.draw(new_sprite)
      horizontal_texture.draw(connector)
      horizontal_texture.draw(cur_sprite)

      return SF::Sprite.new(horizontal_texture.texture)
    end

    private def vertical_connection(dir : Direction) : SF::Sprite
      connect_coords = grid.exits[dir]
      connect_texture = SF::RenderTexture.new(500, 100)

      (0...5).each do |n|
        rect = SF::RectangleShape.new({100, 100})
        rect.position = {n * 100, 0}

        rect.fill_color = if connect_coords.contains?(n)
          SF::Color::White
        else
          SF::Color.new(150, 150, 150)
        end

        connect_texture.draw(rect)
      end

      return SF::Sprite.new(connect_texture.texture)
    end

    def vertical_sprite(new_grid : Grid, dir : Direction) : SF::Sprite
      vertical_texture = SF::RenderTexture.new(500, 1100)
      new_sprite = GridSprite.new(new_grid).grid_sprite
      connector = vertical_connection(dir)
      cur_sprite = grid_sprite

      case dir
        when Direction::Left
          new_sprite.position = {0, 0}
          connector.position = {0, 500}
          cur_sprite.position = {0, 600}
        when Direction::Right
          new_sprite.position = {0, 600}
          connector.position = {0, 500}
          cur_sprite.position = {0, 0}
      end

      vertical_texture.draw(new_sprite)
      vertical_texture.draw(connector)
      vertical_texture.draw(cur_sprite)

      return SF::Sprite.new(vertical_texture.texture)
    end
  end
end
