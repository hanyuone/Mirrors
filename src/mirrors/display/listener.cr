require "./button.cr"

module SF
  class Sprite
    def in_bounds?(pos : SF::Vector2i) : Bool
      bounds = self.global_bounds
      in_width = bounds.left < pos[0] < bounds.left + bounds.width
      in_height = bounds.top < pos[1] < bounds.top + bounds.height

      return in_width && in_height
    end
  end
end

module Mirrors
  class Listener
    getter :draggables, :buttons
    @draggables : Array(SF::Sprite)
    @buttons : Array(Button)

    @mouse_pos : Tuple(Int32, Int32)

    def initialize
      @draggables = [] of SF::Sprite
      @buttons = [] of Button

      @mouse_pos = {-1, -1}
    end

    def add_draggable(sprite : SF::Sprite)
      @draggables.unshift(sprite)
    end

    def add_button(button : Button)
      @buttons.unshift(button)
    end

    def listen(pos : SF::Vector2i)
      @draggables.each do |sprite|
        if sprite.in_bounds?(pos) && @mouse_pos != {-1, -1}
          cur_pos = sprite.position
          sprite.position = {cur_pos[0] + (pos[0] - @mouse_pos[0]), cur_pos[1] + (pos[1] - @mouse_pos[1])}

          @mouse_pos = pos
          return
        end
      end

      @buttons.each do |button|
        if sprite.in_bounds?(pos) && @mouse_pos != {-1, -1}
          button.run
        end
      end

      @mouse_pos = pos
    end

    def reset
      @mouse_pos = {-1, -1}
    end
  end
end