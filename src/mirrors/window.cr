require "crsfml"
require "./display/display.cr"

module Mirrors
  class Window
    @window : SF::RenderWindow
    @display : Display?
    
    def initialize
      @window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "Mirrors")
    end

    def display=(display : Display)
      display.draw
      @display = display
    end

    def show
      while @window.open?
        while (event = @window.poll_event)
          case event
            when SF::Event::Closed
              @window.close
            when SF::Event::MouseButtonPressed
              mouse_pos = SF::Mouse.get_position(@window)
              @display.listener.listen(mouse_pos) unless @display.nil? || @display.listener.nil?
          end
        end

        @display.listener.reset unless @display.nil? || @display.listener.nil?

        sprite = SF::Sprite.new(@display.not_nil!.draw)
        sprite.position = {0, 0}
        
        @window.clear
        @window.draw(sprite)
        @window.display
      end
    end
  end
end