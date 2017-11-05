module Mirrors
  class Game
    @current_display : Display
    @window : Window

    def initialize
      grid = Mirrors::LevelReader.parse("resources/level1.json")
      @current_display = Mirrors::LevelDisplay.new(grid)
      
      @window = Mirrors::Window.new(@current_display)
    end

    def run
      @window.show
    end
  end
end