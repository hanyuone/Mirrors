# Extension of SF::Sprite, to check if a certain position
# is inside the sprite itself
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
  # Event listener class - listenes for events such as mouse
  # clicks and dragging, which therefore triggers either:
  # - an item being dragged, or
  # - a button being clicked
  class Listener
    getter :prev_pos, :mouse_pos, :has_reset
    # A constant signifying an "empty" position
    POS_NIL = {-1, -1}

    # An array of items (either sprites or buttons), and whether
    # they're "locked" in that position or not
    @items : Array(Tuple(SF::Sprite, Bool))
    # The previous position the mouse has been in
    @prev_pos : Tuple(Int32, Int32)
    # The current position the mouse is in
    @mouse_pos : Tuple(Int32, Int32)

    # A flag for if the listener was just reset
    @has_reset : Bool

    # Initialise all of the variables
    def initialize
      @items = [] of Tuple(SF::Sprite, Bool)
      @prev_pos = POS_NIL
      @mouse_pos = POS_NIL
      @has_reset = false
    end

    # Add an item to the listener - it's important that
    # the most recently added item is at the top of the list
    def add_item(item : SF::Sprite, locked : Bool = false)
      @items.unshift({item, locked})
    end

    # A function which takes a position as a coordinate (from
    # a mouse click), and moves items/activates buttons accordingly
    def listen(pos : Tuple(Int32, Int32))
      # Once the first "listen" loop is set, the listener is no longer
      # recently reset, therefore we set it to false
      @has_reset = false
      # The index of the most recently activated item, we need it later
      clicked_item = -1

      # Finds the currently activated item
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

    # Resets the listener, i.e. wipes the mouse states and activates
    # any buttons that were recently clicked
    def reset
      @has_reset = true
      
      # For each of the items, check if the item has been clicked and is
      # a button.
      if @prev_pos == POS_NIL
        @items.map { |item| item[0] }.each do |item|
          next unless item.in_bounds?(@mouse_pos)
          item.run if item.is_a?(Button)
          break
        end
      end

      @prev_pos = POS_NIL
      @mouse_pos = POS_NIL
    end

    # We redefine the getter of `@items`, to make the list
    # more accessible to outside of the listener
    def items
      return @items.map { |item| item[0] }.reverse
    end
  end
end