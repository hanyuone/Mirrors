require "crsfml"
require "../../alias.cr"
require "./sf_extensions.cr"
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
    @prev_pos : Coords
    # The current position the mouse is in
    @mouse_pos : Coords

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
    def listen(pos : Coords)
      # Once the first "listen" loop is set, the listener is no longer
      # recently reset, therefore we set it to false
      @has_reset = false
      # The index of the most recently activated item, we need it later
      clicked_item = @items.index { |item| item[0].in_bounds?(pos) }

      return if clicked_item.nil?

      if @mouse_pos != POS_NIL && !@items[clicked_item][1]
        item = @items[clicked_item]
        current_pos = item[0].position
        item[0].position = {current_pos[0] + pos[0] - @mouse_pos[0], current_pos[1] + pos[1] - @mouse_pos[1]}
      end

      cloned_item = @items.delete_at(clicked_item)
      @items.unshift(cloned_item)

      @prev_pos = @mouse_pos
      @mouse_pos = pos
    end

    def listen_hover(pos : Coords)
      @items.map { |item| item[0] }.each do |item|
        item.exit_hover_fn.try(&.call)
      end

      hovered_item = @items.map { |item| item[0] }.find { |item| item.in_bounds?(pos) }

      return if hovered_item.nil?

      hovered_item.hover_fn.try(&.call)
    end

    # Resets the listener, i.e. wipes the mouse states and activates
    # any buttons that were recently clicked
    def reset
      @has_reset = true
      
      # For each of the items, check if the item has been clicked and is
      # a button.
      if @prev_pos == POS_NIL
        run_item = @items
          .map { |item| item[0] }
          .find { |item| item.in_bounds?(@mouse_pos) }
        puts @mouse_pos
        run_item.run if run_item.is_a?(Button)
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