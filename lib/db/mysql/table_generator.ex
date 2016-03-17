defmodule ModelGenerator.Db.Mysql.TableGenerator do
  require Logger
  alias Mariaex.Connection
  alias ModelGenerator.Db.Table
  alias ModelGenerator.Db.Column
  alias ModelGenerator.Db.Key

  def generate_from_table_data(table_data) do
    Logger.debug(table_data[:table_name])
    Logger.debug(table_data[:create_sentence])
    create_sentence = table_data[:create_sentence]
    sentence_list = String.split(create_sentence, ~r{\n})

    columns = extract_data(sentence_list, &is_column_data?/1, &generate_column_data/1)
    keys = extract_data(sentence_list, &is_key_data?/1, &generate_key_data/1)

    Table.new(columns, keys)
  end

  def extract_data(sentence_list, is_target_data?, generate_target_data) do
    Enum.filter(sentence_list, fn(x) -> is_target_data?.(x) end)
    |> Enum.map(fn(x) -> generate_target_data.(x) end)
  end

  def is_column_data?(""), do: false
  def is_column_data?(sentence) do
    String.strip(sentence)
    |> String.split(" ", trim: true)
    |> List.first
    |> String.starts_with?("\`")
  end

  def generate_column_data(sentence) do
    column_name = extract_column_name(sentence)
    type = extract_column_type(sentence)
    not_null = Regex.run(~r/NOT NULL/, sentence) != nil
    default = extract_default_value(sentence)
    length = extract_length(sentence)
    decimal = extract_decimal(sentence)
    Column.new(column_name, type, not_null, default, length, decimal)
  end

  defp extract_decimal(sentence) do
    regex_result = Regex.run(~r/(?<=\(\d\,).*?(?=\))/, sentence)
    if (regex_result != nil) do
      [desimal_str|_] = regex_result
      String.to_integer(desimal_str)
    end
  end

  defp extract_column_name(sentence) do
    #Regex.run(~r/(?<= )(tinyint|smallint|mediumint|int|integer|bigint|bit|real|double|float|decimal|numeric|char|varchar|date|time|year|timestamp|datetime|blob|tinyblob|mediumblob|longblob|tinytext|text|mediumtext|longtext|enum|set|binary|varbinary|point|linestring|poligon|geometry|multipoint|multilinestring|multipoligon|geometrycollection)/, sentence)
    Regex.run(~r/(?<=`).*?(?=`)/, sentence)
    |> List.first
  end

  defp extract_column_type(sentence) do
    Regex.run(~r/(?<=` ).*?(?=\(| )/, sentence)
    |> List.first
  end

  defp extract_length(sentence) do
    regex_result = Regex.run(~r/(?<=\().*?(?=\)|,)/, sentence)
    if(regex_result != nil) do
      [length_str|_] = regex_result
      String.to_integer(length_str)
    end
  end

  defp extract_default_value(sentence) do
    regex_result = Regex.run(~r/(?<=DEFAULT ).*?(?=,)/, sentence)
    if (regex_result != nil) do
      [default_str|_] = regex_result
      default_str
    end
  end

  def is_key_data?(""), do: false
  def is_key_data?(sentence) do
    str = String.strip(sentence)
    String.starts_with?(str, "KEY") || String.starts_with?(str, "PRIMARY KEY") || String.starts_with?(str, "UNIQUE KEY")
  end

  def generate_key_data(sentence) do
    name = extract_key_name(sentence)
    type = extract_key_type(sentence)
    columns = extract_key_columns(sentence)
    Key.new(name, type, columns)
  end

  defp extract_key_name(sentence) do
    name_pattern = Regex.run(~r/(?<= `).*?(?=` )/, sentence)
    if (name_pattern != nil) do
      List.first(name_pattern)
    end
  end

  defp extract_key_type(sentence) do
    str = String.strip(sentence)
    cond do
      String.starts_with?(str, "KEY") -> :key
      String.starts_with?(str, "PRIMARY KEY") -> :primary
      String.starts_with?(str, "UNIQUE KEY") -> :unique
    end
  end

  defp extract_key_columns(sentence) do
    Regex.run(~r/(?<=\().*?(?=\))/,sentence)
    |> List.first
    |> String.replace("`","")
    |> String.split(",")
  end

  def table_list(conn, schema) do

  end

  def get_table_data(hostname, port, database, username, password, table) do
    {:ok, p} = Connection.start_link(hostname: hostname, port: port, username: username, password: password, database: database)
    Connection.query(p, table_query(table))
    |> extract_table_data
  end

  defp extract_table_data({:ok, %Mariaex.Result{rows: rows}}) do
    # get first element.
    [h|_] = rows
    # first element is table_name, second element is create_sentence.
    [table_name| [create_sentence | _tail]] = h
    %{table_name: table_name, create_sentence: create_sentence}
  end

  defp table_list_query(schema) do
    "SHOW TABLES FROM #{schema};"
  end

  defp table_query(table) do
    "SHOW CREATE TABLE #{table};"
  end
end
