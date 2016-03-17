defmodule ModelGenerator.File.Creator do
  def createFile(path, fileName, content) do
    case File.open "#{path}/#{fileName}", [:write] do
      {:ok, file} ->
        IO.binwrite file, content
        File.close file
      {:error, message} ->
        {:error, "can't create a file!"}
    end
  end
end
