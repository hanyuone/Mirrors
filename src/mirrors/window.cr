require "crsfml"
require "./display/display.cr"

module Mirrors
  class Window
    property :display
    @window : SF::RenderWindow
    @display : Display?
    
    def initialize
      @window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "Mirrors")
    end

    private def display_items
      sprite = SF::Sprite.new(@display.not_nil!.draw)
      sprite.position = {0, 0}
      
      @window.clear
      @window.draw(sprite)
      @window.display
    end

    private def listen_once
      mouse_pos = SF::Mouse.get_position(@window)
      @display.try(&.listener).try(&.listen({mouse_pos[0], mouse_pos[1]}))
    end

    private def click_loop
      until (event = @window.poll_event).is_a?(SF::Event::MouseButtonReleased)
        listen_once if event.is_a?(SF::Event::MouseMoved)
        display_items
      end
    end

    def show
      while @window.open?
        while (event = @window.poll_event)
          case event
            when SF::Event::Closed
              @window.close
            when SF::Event::MouseButtonPressed
              listen_once
              click_loop
              
              @display.try(&.listener).try(&.reset)
          end
        end

        display_items
      end
    end
  end
end
