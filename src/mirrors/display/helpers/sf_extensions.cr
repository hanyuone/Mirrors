module SF
  # Extension of SF::Sprite, to check if a certain position
  # is inside the sprite itself
  class Sprite
    getter :hover_fn, :exit_hover_fn
    @hover_fn : Proc(Nil)?
    @exit_hover_fn : Proc(Nil)?

    def in_bounds?(pos : Coords) : Bool
      bounds = self.global_bounds
      in_width = bounds.left < pos[0] < bounds.left + bounds.width
      in_height = bounds.top < pos[1] < bounds.top + bounds.height

      return in_width && in_height
    end

    def on_hover(&block : -> Nil)
      @hover_fn = block
    end

    def exit_hover(&block : -> Nil)
      @exit_hover_fn = block
    end
  end

  class Text
    def centre(position : Coords)
      width = self.character_size * self.string.size * 7.0_f64 / 12
      height = self.global_bounds.height

      self.position = {
        position[0] - (width / 2),
        position[1] - height
      }
    end
  end
end