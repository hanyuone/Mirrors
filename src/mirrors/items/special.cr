require "./direction.cr"

module Mirrors
  alias Coords = Tuple(Int32, Int32)

  abstract class Special
    abstract def apply(light : Light)
  end

  # Left and right mirrors
  class LeftMirror < Special
    def initialize; end
    
    def apply(light : Light)
      change_dirs = {
        Direction::Left => Direction::Down,
        Direction::Right => Direction::Up,
        Direction::Up => Direction::Right,
        Direction::Down => Direction::Left
      }

      light.dir = change_dirs[light.dir]
    end
  end

  class RightMirror < Special
    def initialize; end

    def apply(light : Light)
      change_dirs = {
        Direction::Left => Direction::Up,
        Direction::Right => Direction::Down,
        Direction::Up => Direction::Left,
        Direction::Down => Direction::Right
      }

      light.dir = change_dirs[light.dir]
    end
  end

  # Teleporter
  class Teleporter < Special
    @dest : Coords

    def initialize(@dest); end

    def apply(light : Light)
      light.coords = @dest
      light.teleported = true
    end
  end

  # Block (prevents light from passing)
  class Block < Special
    def initialize; end

    def apply(light : Light)
      light.dir = Direction::None
    end
  end

  # Switch - toggles various tiles on the board to
  # one of two states each.
  class Switch
    property :items
    @items : Array(Tuple(Coords, Special?, Special?))

    def initialize(@items); end
  end
end