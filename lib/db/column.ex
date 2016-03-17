defmodule ModelGenerator.Db.Column do
  defstruct name: nil, type: nil, length: nil, decimals: nil, not_null: false, default: nil

  def new(name, type, not_null, default, length, decimals) do
    %ModelGenerator.Db.Column{name: name, type: type, length: length, decimals: decimals, not_null: not_null, default: default}
  end

  def new(name, type, not_null, default, length) do
    new(name, type, not_null, default, length, nil)
  end

  def new(name, type, not_null, default) do
    new(name, type, not_null, default, nil, nil)
  end

  def new(name, type, not_null) do
    new(name, type, not_null, nil)
  end

end
