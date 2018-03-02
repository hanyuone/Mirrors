require "crsfml"
require "../gui/*"
require "./level_display.cr"

module Mirrors
  class StartDisplay < Display
    @font = SF::Font.from_file("../resources/FiraCode.ttf")

    private def add_start_buttons
      play_text = SF::Text.new("Play", @font)
      play_text.centre({100, 20})
      play_text.fill_color = SF::Color.new(100, 100, 100)

      play_texture = SF::RenderTexture.new(200, 40)
      play_texture.clear
      play_texture.draw(play_text)
      play_texture.display

      hover_text = SF::Text.new("Play", @font)
      hover_text.centre({100, 20})
      hover_text.fill_color = SF::Color::White

      hover_texture = SF::RenderTexture.new(200, 40)
      hover_texture.clear
      hover_texture.draw(hover_text)
      hover_texture.display

      play_button = Button.new(play_texture.texture, hover_texture.texture) do
        @new_display = LevelDisplay.new(1)
      end

      play_button.position = {300, 280}

      @listener.add_item(play_button, true)
    end

    def initialize
      super
      add_start_buttons
    end

    private def draw_logo
      logo = SF::Text.new("MIRRORS", @font)
      logo.character_size = 50
      logo.centre({400, 80})
      logo.fill_color = SF::Color::White

      @texture.draw(logo)
    end

    def draw
      draw_listener
      draw_logo
    end
  end
end
