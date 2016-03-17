defmodule ModelGenerator.File.CreatorTest do
  use PowerAssert
  # doctest ModelGenerator.File.Creator

  test "create relative path file" do
    path = "test/file"
    fileName = "text.exs"
    content = "test"
    assert :ok == ModelGenerator.File.Creator.createFile(path, fileName, content)
    assert {:ok, "test"} == File.read "test/file/text.exs"
  end

  test "create absolute path file" do
    path = "/data/test"
    fileName = "text.exs"
    content = "test"
    assert :ok == ModelGenerator.File.Creator.createFile(path, fileName, content)
    assert {:ok, "test"} == File.read "/data/test/text.exs"
  end

  test "create to unexist path" do
    path = "/notexist/data/test"
    fileName = "text.exs"
    content = "test"
    {:error, message} = ModelGenerator.File.Creator.createFile(path, fileName, content)
    assert message == "can't create a file!"
  end

  test "create multi line file" do
    path = "test/file"
    fileName = "text2.exs"
    content = "test\ntest"
    assert :ok == ModelGenerator.File.Creator.createFile(path, fileName, content)
    assert {:ok, "test\ntest"} == File.read "test/file/text2.exs"
  end
end
