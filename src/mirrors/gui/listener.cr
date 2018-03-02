require "../alias.cr"
require "./hover_sprite.cr"

module Mirrors
  class Listener
    getter items : Array(Tuple(HoverSprite, Bool)) = [] of Tuple(HoverSprite, Bool)

    @mouse_pos : Coords? = nil
    @prev_mouse_pos : Coords? = nil

    @hovered_index : Int32? = nil

    getter has_reset = false

    def initialize; end

    def add_item(item : HoverSprite, locked : Bool = false)
      @items.unshift({item, locked})
    end

    def wipe
      @items = [] of Tuple(HoverSprite, Bool)
    end

    private def move_item(index : Int32)
      return if @prev_mouse_pos.nil? || @items[index][1]

      item = @items[index][0]

      if (mouse_pos = @mouse_pos) && (prev_mouse_pos = @prev_mouse_pos)
        difference = {mouse_pos[0] - prev_mouse_pos[0], mouse_pos[1] - prev_mouse_pos[1]}
      else
        return
      end
      
      item.position = {item.position[0] + difference[0], item.position[1] + difference[1]}
    end

    def listen(pos : Coords)
      if (hovered_index = @hovered_index)
        @items[hovered_index][0].exited
      end

      @has_reset = false

      @prev_mouse_pos = @mouse_pos
      @mouse_pos = pos

      clicked_index = @items.index { |tup| tup[0].in_bounds?(pos) }

      return if clicked_index.nil?

      # Move the item to the dragged place
      move_item(clicked_index)

      # Move the item to the front of the "queue"
      moved_item = @items.delete_at(clicked_index)
      @items.unshift(moved_item)
    end

    def listen_hover(pos : Coords)
      hover_index = @items.index { |tup| tup[0].in_bounds?(pos) }
      return if @hovered_index == hover_index

      if (hovered_index = @hovered_index)
        @items[hovered_index][0].exited
      end

      if hover_index.nil?
        @hovered_index = nil
        return
      end

      @items[hover_index][0].hovered
      @hovered_index = hover_index
    end

    # Resets the listener
    def reset
      @has_reset = true

      if !@mouse_pos.nil? && @prev_mouse_pos.nil?
        current_item = @items[0][0]
        current_item.run if current_item.is_a?(Button)
      end

      @mouse_pos = nil
      @prev_mouse_pos = nil
    end
  end
end
