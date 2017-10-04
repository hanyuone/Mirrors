require "./spec_helper"

macro to_arr(tname, *args)
  ([] of {{ tname }})
  {{ for name, index in args }}
    .concat([ {{ name }} ])
  {{ end }}
end

describe Mirrors do
  # TODO: Write tests

  it "LeftMirror test" do
    grid = Mirrors::Grid.new([
      ([] of Bool?).concat([false, false]),
      ([] of Bool?).concat([false, nil])
    ], [
      ([] of Mirrors::Item?).concat([]),
    ])
  end
end
