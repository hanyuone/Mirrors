require "crsfml"

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
          if event.is_a?(SF::Event::Closed)
            @window.close
          end
        end

        sprite = SF::Sprite.new(@display.not_nil!.draw)
        sprite.position = {0, 0}
        
        @window.clear
        @window.draw(sprite)
        @window.display
      end
    end
  end
end