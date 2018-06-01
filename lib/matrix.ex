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
            |> Enum.map( fn(_) -> 0 end )
        end )
    end
  end


  def get(matrix) when is_pid(matrix) do
    Agent.get matrix, fn(x) -> x end
  end


  def update(matrix, val) do
    Agent.update matrix, fn(_) -> val end
  end


  def add(matrix, x) when is_number x do
    new_val = Matrix.map(matrix, fn(cell) ->
      cell + x
    end)
    Matrix.update(matrix, new_val)
    new_val
  end

  def add(mat1, mat2) when
    is_list mat2 do
  end


  def add(matrix, x) when is_number x do
    new_val = Matrix.map(matrix, fn(cell) ->
      cell - x
    end)
    Matrix.update(matrix, new_val)
    new_val
  end


  def map(matrix, foo) when is_pid(matrix) do
    mat = Matrix.get matrix
    Matrix.map(mat, foo)
  end

  def map(matrix, foo) when is_list(matrix) do
    Enum.map(matrix, fn(rows) ->
      Enum.map(rows, foo)
    end)
  end


  def multiply(matrix, x) when is_number x do
    new_val = Matrix.map matrix, fn(c) -> c * x end
    Matrix.update(matrix, new_val)
    new_val
  end



end
