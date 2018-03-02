require "../alias.cr"
require "./direction.cr"

module Mirrors
  abstract class Item
    abstract def apply(light : Light)
  end

  # Left and right mirrors
  class LeftMirror < Item
    CHANGE_DIRS = {
      Direction::Left => Direction::Down,
      Direction::Right => Direction::Up,
      Direction::Up => Direction::Right,
      Direction::Down => Direction::Left
    }

    def initialize; end
    
    def apply(light : Light)
      light.dir = CHANGE_DIRS[light.dir]
    end
  end

  class RightMirror < Item
    CHANGE_DIRS = {
      Direction::Left => Direction::Up,
      Direction::Right => Direction::Down,
      Direction::Up => Direction::Left,
      Direction::Down => Direction::Right
    }

    def initialize; end

    def apply(light : Light)
      light.dir = CHANGE_DIRS[light.dir]
    end
  end

  # Teleporter
  class Teleporter < Item
    getter dest : LevelCoords

    def initialize(@dest); end

    def apply(light : Light)
      if (dest = @dest)
        light.coords = dest
        light.teleported = true
      end
    end
  end

  # Block (prevents light from passing)
  class Block < Item
    def initialize; end

    def apply(light : Light)
      light.dir = nil
    end
  end

  # One-way tiles
  class HorizontalOnly < Item
    def initialize; end

    def apply(light : Light)
      light.dir = nil if light.dir.is_a?(Direction::Up | Direction::Down)
    end
  end

  class VerticalOnly < Item
    def initialize; end

    def apply(light : Light)
      light.dir = nil if light.dir.is_a?(Direction::Left | Direction::Right)
    end
  end

  # Switch - toggles various tiles on the board to
  # one of two states each.
  class Switch < Item
    getter   target  : LevelCoords
    property active  : Item?
    property passive : Item?

    def initialize(@target, @active, @passive); end

    def apply(light : Light); end
  end
end
