require "crsfml"
require "./display/helpers/display.cr"

module Mirrors
  # The main window class.
  class Window
    property :display
    # The window where the display is going to be drawn
    @window : SF::RenderWindow
    # The display with the relevant content on it
    @display : Display
    
    # Initialise function
    def initialize(@display)
      @window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "Mirrors")
      @window.vertical_sync_enabled = true
    end

    # Place `@display` on the screen.
    private def display_items
      @window.clear
      @window.draw(@display.screen.not_nil!)
      @window.display
    end

    # Run the listener once, and execute any changes.
    private def listen_once
      mouse_pos = SF::Mouse.get_position(@window)
      @display.listener.listen({mouse_pos[0], mouse_pos[1]})
    end

    # This continues running until the user has released their left mouse button.
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
              break unless event.button == SF::Mouse::Button::Left
              listen_once
              click_loop
              
              @display.listener.reset
          end
        end

        display_items
      end
    end
  end
end
