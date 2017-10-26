module Mirrors
  class Button
    getter :sprite, :fn
    @sprite : SF::Sprite
    @fn : Void -> Void

    def initialize(@sprite, @fn); end
    def run; @fn.call; end
  end
end