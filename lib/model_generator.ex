defmodule ModelGenerator do
  alias ModelGenerator.Db.Mysql.TableGenerator

  def create(table_name) do
    hostname = Application.get_env(:model_generator, :db_host)
    port = Application.get_env(:model_generator, :db_port)
    database = Application.get_env(:model_generator, :db_name)
    username = Application.get_env(:model_generator, :db_user)
    password = Application.get_env(:model_generator, :db_pass)

    TableGenerator.get_table_data(hostname, port, database, username, password, table_name)
    |> TableGenerator.generate_from_table_data
  end
end
