require "crsfml"

require "./gui/display.cr"

module Mirrors
  # The main window class.
  class Game
    # The window where the display is going to be drawn
    @window : SF::RenderWindow
    # The display with the relevant content on it
    @display : Display
    
    # Initialise function
    def initialize
      @window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "Mirrors")
      @window.vertical_sync_enabled = true
      
      @display = StartDisplay.new
    end

    # Place `@display` on the screen.
    private def place_display
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
        next if event.is_a?(Nil)

        listen_once if event.is_a?(SF::Event::MouseMoved)
        place_display
      end
    end

    def run
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
            when SF::Event::MouseMoved
              mouse_pos = SF::Mouse.get_position(@window)
              @display.listener.listen_hover({mouse_pos[0], mouse_pos[1]})
            else
              @display.event = event
          end
        end

        place_display

        if @display.new_display.is_a?(Display)
          @display.listener.wipe
          @display = @display.new_display.not_nil!
        end
      end
    end
  end
end
