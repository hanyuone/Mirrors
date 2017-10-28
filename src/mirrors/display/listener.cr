module SF
  class Sprite
    def in_bounds?(pos : Tuple(Int32, Int32)) : Bool
      bounds = self.global_bounds
      in_width = bounds.left < pos[0] < bounds.left + bounds.width
      in_height = bounds.top < pos[1] < bounds.top + bounds.height

      return in_width && in_height
    end
  end
end

require "./button.cr"

module Mirrors
  class Listener
    getter :items
    POS_NIL = {-1, -1}

    @items : Array(SF::Sprite)
    @prev_pos : Tuple(Int32, Int32)
    @mouse_pos : Tuple(Int32, Int32)

    def initialize
      @items = [] of SF::Sprite
      @prev_pos = POS_NIL
      @mouse_pos = POS_NIL
    end

    def add_item(item : SF::Sprite)
      @items.unshift(item)
    end

    def listen(pos : Tuple(Int32, Int32))
      @items.each do |item|
        next unless item.in_bounds?(pos)

        if @mouse_pos != POS_NIL
          current_pos = item.position
          item.position = {current_pos[0] + (pos[0] - @mouse_pos[0]), current_pos[1] + (pos[1] - @mouse_pos[1])}
        end

        break
      end

      @prev_pos = @mouse_pos
      @mouse_pos = pos
    end

    def reset
      @items.each do |item|
        next unless item.in_bounds?(@mouse_pos)
        item.run if item.is_a?(Button) && @prev_pos == POS_NIL
        break
      end

      @prev_pos = POS_NIL
      @mouse_pos = POS_NIL
    end
  end
end