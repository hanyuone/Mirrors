module SF
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
