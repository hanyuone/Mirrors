require "../alias.cr"
require "./item.cr"
require "./direction.cr"

module Mirrors
  abstract class Special
    abstract def apply(light : Light)
  end

  # Left and right mirrors
  class LeftMirror < Special
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

  class RightMirror < Special
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
  class Teleporter < Special
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
  class Block < Special
    def initialize; end

    def apply(light : Light)
      light.dir = nil
    end
  end

  # One-way tiles
  class HorizontalOnly < Special
    def initialize; end

    def apply(light : Light)
      light.dir = nil if light.dir.is_a?(Direction::Up | Direction::Down)
    end
  end

  class VerticalOnly < Special
    def initialize; end

    def apply(light : Light)
      light.dir = nil if light.dir.is_a?(Direction::Left | Direction::Right)
    end
  end

  # Switch - toggles various tiles on the board to
  # one of two states each.
  class Switch
    getter target  : LevelCoords
    property active  : Item?
    property passive : Item?

    def initialize(@target, @active, @passive); end
  end
end
