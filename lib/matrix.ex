defmodule Matrix do
  use Agent

  def new(rows, cols) do
    {:ok, matrix} = Matrix.start_link rows, cols
    matrix
  end


  def from_list(list) do
    {:ok, matrix} = Agent.start fn -> list end
    matrix
  end


  def start_link(rows, cols) do
    # Create matrix
    Agent.start fn ->
      Enum.to_list(1..rows)
        |> Enum.map( fn(_) ->
          Enum.to_list(1..cols)
            |> Enum.map( fn(_) -> 0.0 end )
        end )
    end
  end


  def at(matrix, row, col) do
    cond do
      is_pid(matrix) ->
        Matrix.get(matrix)
        |> Matrix.at(row, col)

      is_list(matrix) ->
        Enum.at(matrix, row)
        |> Enum.at(col)

      true -> {:error, "Invalid matrix"}
    end
  end

  def at(matrix, row) do
    cond do
      is_pid(matrix) ->
        Matrix.get(matrix)
        |> Matrix.at(row)

      is_list(matrix) ->
        Enum.at(matrix, row)

      true -> {:error, "Invalid matrix"}
    end
  end


  def shape(matrix) when is_pid(matrix) do
    Matrix.get(matrix)
    |> Matrix.shape
  end

  def shape(matrix) when is_list(matrix) do
    {Kernel.length(matrix), Kernel.length(matrix[0])}
  end


  def print(matrix) when is_pid(matrix) do
    Matrix.get(matrix)
    |> Matrix.print
  end

  def print(matrix) when is_list(matrix) do
    IO.inspect(matrix, charlists: :as_lists)
  end


  def get(matrix) when is_pid(matrix) do
    Agent.get matrix, fn(x) -> x end
  end


  def update(matrix, val) do
    Agent.update matrix, fn(_) -> val end
  end


  def merge_with(mat1, mat2, foo) when is_pid(mat1) and is_pid(mat2) do
    m1 = Matrix.get(mat1)
    m2 = Matrix.get(mat2)

    new_val = Matrix.merge_with(m1, m2, foo)
    Matrix.update mat1, new_val
    new_val
  end

  def merge_with(mat1, mat2, foo) when is_list(mat1) and is_list(mat2) do
    Enum.with_index(mat1)
    |> Enum.map(fn({row1, y}) ->
      Enum.with_index(row1)
      |> Enum.map(fn({c1, x}) ->
        {v1, v2} = {c1, Matrix.at(mat2,y,x)}
        foo.(v1, v2)
      end)
    end)
  end


  def add(matrix, x) when is_number x do
    new_val = Matrix.map(matrix, fn(cell) ->
      cell + x
    end)
    Matrix.update(matrix, new_val)
    new_val
  end

  def add(m1, m2) when is_pid(m1) and is_pid(m2) do
    Matrix.merge_with(m1, m2, fn(x,y) -> x + y end)
  end

  def add(mat1, mat2) when is_list(mat2), do: Matrix.merge_with(mat1, mat2, fn(x,y) -> x + y end)


  def sub(matrix, x) when is_number(x) do
    new_val = Matrix.map(matrix, fn(cell) ->
      cell - x
    end)
    Matrix.update(matrix, new_val)
    new_val
  end


  def map(matrix, foo) do
    cond do
      is_pid(matrix) ->
        Matrix.map(Matrix.get(matrix), foo)

      is_list(matrix) ->
        Enum.map(matrix, fn(rows) ->
          Enum.map(rows, foo)
        end)

    end
  end


  def multiply(matrix, x) do
    cond do
      is_pid(matrix) -> Matrix.multiply(Matrix.get(matrix), x)


      is_number(x) ->
        Matrix.map matrix, fn(c) -> c * x end

      is_pid(x) ->
        Matrix.multiply(matrix, Matrix.get(x))

      is_list(x) ->
        Matrix.product matrix, x
    end
  end


  def product(m1, m2) do
    cond do
      is_pid(m1) and is_pid(m2) -> Matrix.product(Matrix.get(m1), Matrix.get(m2))
      is_pid(m1) -> Matrix.product(Matrix.get(m1), m2)
      is_pid(m2) -> Matrix.product(m1, Matrix.get(m2))

      # Credit: https://rosettacode.org/wiki/Matrix_multiplication#Elixir
      is_list(m1) and is_list(m2) ->
        Enum.map m1, fn (x) ->
          Enum.map Matrix.transpose(m2), fn (y) ->
            Enum.zip(x, y)
            |> Enum.map(fn {x, y} -> x * y end)
            |> Enum.sum
        end
      end

    end
  end


  def transpose(mat) do
    List.zip(mat) |> Enum.map(&Tuple.to_list(&1))
  end


  def rand(matrix), do: Matrix.update matrix, Matrix.map(matrix, fn(_) -> :rand.uniform() end)


end
