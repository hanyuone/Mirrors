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
    getter :items, :prev_pos, :mouse_pos, :has_reset
    POS_NIL = {-1, -1}

    @items : Array(Tuple(SF::Sprite, Bool))
    @prev_pos : Tuple(Int32, Int32)
    @mouse_pos : Tuple(Int32, Int32)

    @has_reset : Bool

    def initialize
      @items = [] of Tuple(SF::Sprite, Bool)
      @prev_pos = POS_NIL
      @mouse_pos = POS_NIL
      @has_reset = false
    end

    def add_item(item : SF::Sprite, locked : Bool = false)
      @items.unshift({item, locked})
    end

    def listen(pos : Tuple(Int32, Int32))
      @has_reset = false
      clicked_item = -1

      (0...@items.size).each do |a|
        item = @items[a]
        next if item[1] || !item[0].in_bounds?(pos)

        clicked_item = a

        if @mouse_pos != POS_NIL
          current_pos = item[0].position
          item[0].position = {current_pos[0] + pos[0] - @mouse_pos[0], current_pos[1] + pos[1] - @mouse_pos[1]}
        end

        break
      end

      cloned_item = @items.delete_at(clicked_item)
      @items.unshift(cloned_item)

      @prev_pos = @mouse_pos
      @mouse_pos = pos
    end

    def reset
      @has_reset = true
      
      @items.map { |item| item[0] }.each do |item|
        next unless item.in_bounds?(@mouse_pos)
        item.run if item.is_a?(Button) && @prev_pos == POS_NIL
        break
      end

      @prev_pos = POS_NIL
      @mouse_pos = POS_NIL
    end

    def items
      return @items.map { |item| item[0] }.reverse
    end
  end
end