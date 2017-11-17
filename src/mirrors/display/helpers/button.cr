require "crsfml"
require "./sf_extensions.cr"

module Mirrors
  class Button < SF::Sprite
    @fn : Proc(Nil)

    def initialize(texture : SF::Texture, @fn)
      super texture
    end

    def run
      @fn.call
    end
  end
end