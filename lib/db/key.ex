defmodule ModelGenerator.Db.Key do
  defstruct name: nil, type: nil, columns: []

  @key_types [:primary, :unique, :key]
  def new(name, type, columns) when type in @key_types and length(columns) != 0 do
    %ModelGenerator.Db.Key{name: name, type: type, columns: columns}
  end

  def new(name, type, columns) do
    raise "Illegal arguments! name: #{name}, type: #{type}, columns: #{columns}"
  end
end
