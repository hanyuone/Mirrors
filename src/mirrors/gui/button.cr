require "./hover_sprite.cr"

module Mirrors
  class Button < HoverSprite
    @on_click : Proc(Nil)

    def initialize(texture : SF::Texture, &fn : -> Nil)
      super texture
      @on_click = fn
    end

    def initialize(texture : SF::Texture, hover_texture : SF::Texture, &fn : -> Nil)
      super texture, hover_texture
      @on_click = fn
    end

    def run
      @on_click.call
    end
  end
end
