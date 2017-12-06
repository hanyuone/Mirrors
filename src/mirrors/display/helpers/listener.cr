require "./hover_sprite.cr"

module Mirrors
  class Listener
    getter :items
    @items : Array(Tuple(HoverSprite, Bool)) = [] of Tuple(HoverSprite, Bool)

    @mouse_pos = {-1, -1}
    @prev_mouse_pos = {-1, -1}

    @hovered_index = -1

    @has_reset = false

    def initialize; end

    def add_item(item : HoverSprite, locked : Bool = false)
      @items.unshift({item, locked})
    end

    def wipe
      @items = [] of Tuple(HoverSprite, Bool)
    end

    private def move_item(item : HoverSprite)
      return if @prev_pos = {-1, -1}

      difference = {@mouse_pos[0] - @prev_mouse_pos[0], @mouse_pos[1] - @prev_mouse_pos[1]}
      item.position = {item.position[0] + difference[0], item.position[1] + difference[1]}
    end

    def listen(pos : Coords)
      @has_reset = false

      clicked_index = @items.index { |tup| tup[0].in_bounds?(pos) }

      return if clicked_index.nil?

      # Move the item to the dragged place
      clicked_item = @items[clicked_index][0]
      move_item(clicked_item)

      # Move the item to the front of the "queue"
      moved_item = @items.delete_at(clicked_index)
      @items.unshift(moved_item)

      @prev_pos = @mouse_pos
      @mouse_pos = pos
    end

    def listen_hover(pos : Coords)
      hover_index = @items.index { |tup| tup[0].in_bounds?(pos) }
      return if @hovered_index == hover_index

      @items[@hovered_index][0].exited unless @hovered_index == -1

      if hover_index.nil?
        @hovered_index = -1
        return
      end

      @items[hover_index][0].hovered
      @hovered_index = hover_index
    end

    # Resets the listener
    def reset
      @has_reset = true

      if @mouse_pos != {-1, -1} && @prev_pos == {-1, -1}
        current_item = @items[0][0]
        current_item.run if current_item.is_a?(Button)
      end

      @mouse_pos = {-1, -1}
      @prev_pos = {-1, -1}
    end
  end
end