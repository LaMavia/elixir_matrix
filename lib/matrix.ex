defmodule Matrix do
  use Agent

  def create(rows, cols) do
    {:ok, matrix} = Matrix.start_link rows, cols
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


  # def print(matrix) when is_pid(matrix) do
  #   Matrix.get(matrix)
  #   |> Matrix.print
  # end

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
    # mat1 = Matrix.get(m1)
    # mat2 = Matrix.get(m2)

    # new_val = Matrix.add(mat1, mat2)
    # Matrix.update m1, new_val
    # new_val
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


  def multiply(matrix, x) when is_number x do
    new_val = Matrix.map matrix, fn(c) -> c * x end
    Matrix.update(matrix, new_val)
    new_val
  end


  def rand(matrix), do: Matrix.update matrix, Matrix.map(matrix, fn(_) -> :rand.uniform() end)

end
