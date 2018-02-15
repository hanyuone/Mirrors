require "./spec_helper"

describe Mirrors do
  describe "LevelReader" do
    level = Mirrors::LevelParser.parse("resources/levels/0.json")

    it "parses lights properly" do
      light = level.lights[0]
      light.coords.should eq nil
      light.dir.should eq nil
    end

    it "parses grids properly" do
      grids = level.grids[0][0]
      grids.should be_a Grid
    end

    it "parses the tile grid properly" do
      tile_grid = level.grids[0][0].tile_grid
      tile_grid[7].should eq false
      tile_grid[12].should eq false
      tile_grid[17].should eq false
    end
  end
end
