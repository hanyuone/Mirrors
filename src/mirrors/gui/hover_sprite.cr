require "crsfml"

module Mirrors
  class HoverSprite < SF::Transformable
    include SF::Drawable

    property :position
    getter :is_hover

    @texture : SF::Texture
    @hover_texture : SF::Texture
    @hover_fn : Proc(Nil) = ->() {}
    @exit_fn  : Proc(Nil) = ->() {}

    @position = {0, 0}

    @is_hover = false

    private def validate_textures
      unless @texture.size == @hover_texture.size
        raise "The two provided textures have different sizes!"
      end
    end

    def initialize(texture : SF::Texture)
      super()
      @texture = texture
      @hover_texture = texture
      validate_textures
    end

    def initialize(texture : SF::Texture, hover_texture : SF::Texture)
      super()
      @texture = texture
      @hover_texture = hover_texture
      validate_textures
    end

    def on_hover(&fn : -> Nil)
      @hover_fn = fn
    end

    def on_exit(&fn : -> Nil)
      @exit_fn = fn
    end

    def hovered
      @is_hover = true
      @hover_fn.call
    end

    def exited
      @is_hover = false
      @exit_fn.call
    end

    def draw(target : SF::RenderTarget, states : SF::RenderStates)
      sprite = SF::Sprite.new(@is_hover ? @hover_texture : @texture)
      sprite.position = @position
      
      target.draw(sprite)
    end

    def in_bounds?(pos : Coords)
      x_range = {@position[0], @position[0] + @texture.size[0]}
      y_range = {@position[1], @position[1] + @texture.size[1]}

      return (x_range[0] <= pos[0] < x_range[1]) && (y_range[0] <= pos[1] < y_range[1])
    end
  end
end
