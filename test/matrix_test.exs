defmodule MatrixTest do
  use ExUnit.Case
  doctest Matrix

  test "Sums 2 matrices" do
    m1 = Matrix.new 2, 2
    m2 = Matrix.new 2, 2

    Matrix.add m1, 3
    Matrix.add m2, 3

    assert Matrix.add(m1, m2) === [ [6.0, 6.0], [6.0, 6.0] ]
  end

  test "Scales matrix by 2" do
    m1 = Matrix.new 3, 4
    Matrix.add m1, 3

    assert Matrix.multiply(m1, 2)
    === [
      [6.0, 6.0, 6.0, 6.0],
      [6.0, 6.0, 6.0, 6.0],
      [6.0, 6.0, 6.0, 6.0]
    ]
  end
end
