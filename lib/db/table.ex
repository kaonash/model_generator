defmodule ModelGenerator.Db.Table do
  defstruct columns: [], keys: []
  alias ModelGenerator.Db.Column
  alias ModelGenerator.Db.Key

  @spec new([Column.t],[Key.t]) :: Table.t
  def new(columns, keys) do
    %ModelGenerator.Db.Table{columns: columns, keys: keys}
  end
end
