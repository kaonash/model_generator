defmodule ModelGenerator.Db.Mysql.TableGeneratorTest do
  use PowerAssert
  alias ModelGenerator.Db.Mysql.TableGenerator
  alias ModelGenerator.Db.Column
  alias ModelGenerator.Db.Key
  alias ModelGenerator.Db.Table

  test "is column data when the sentence starts with back quote" do
    assert TableGenerator.is_column_data?("  `id` char(12) COLLATE utf8_bin NOT NULL,") == true
  end

  test "is not column data when the sentence starts with alphabet" do
    assert TableGenerator.is_column_data?("CREATE TABLE `test_table` (") == false
  end

  test "is not column data when the sentence starts with the other simbole" do
    assert TableGenerator.is_column_data?("--") == false
  end

  test "is not key data when the sentence doesn't start with KEY or PRIMARY KEY or UNIQUE KEY" do
    assert TableGenerator.is_key_data?("  `id` char(12) COLLATE utf8_bin NOT NULL,") == false
  end

  test "is key data when the sentence starts with KEY or PRIMARY KEY or UNIQUE KEY" do
    assert TableGenerator.is_key_data?("  KEY `index01` (`int_num`,`decimal_num`),") == true
  end

  test "char column data is generated from a column sentence" do
    column = Column.new("id", "char", true, nil, 12)
    assert TableGenerator.generate_column_data("`id` char(12) COLLATE utf8_bin NOT NULL,") == column
  end

  test "timestamp column data is generated from a column sentence" do
    column = Column.new("timestamp", "timestamp", true, "CURRENT_TIMESTAMP")
    assert TableGenerator.generate_column_data("`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,") == column
  end

  test "primary key data is generated from a column sentence" do
    key = Key.new(nil, :primary, ["id"])
    assert TableGenerator.generate_key_data("PRIMARY KEY (`id`),") == key
  end

  test "unique key data is generated from a column sentence" do
    key = Key.new("unique01", :unique, ["name"])
    assert TableGenerator.generate_key_data("UNIQUE KEY `unique01` (`name`),") == key
  end

  test "index key data is generated from a column sentence" do
    key = Key.new("index01", :key, ["int_num", "decimal_num"])
    assert TableGenerator.generate_key_data("KEY `index01` (`int_num`,`decimal_num`),") == key
  end

  test "column data count is column count of create sentence" do
    create_sentence =
    """
    CREATE TABLE `test_table` (
    `id` char(12) COLLATE utf8_bin NOT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `name` varchar(150) COLLATE utf8_bin NOT NULL,
    `int_num` int(1) DEFAULT '0',
    `decimal_num` decimal(8,2) DEFAULT NULL,
    `double_num` double DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique01` (`name`),
    KEY `index01` (`int_num`,`decimal_num`),
    KEY `index02` (`double_num`),
    KEY `index03` (`timestamp`) USING BTREE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
    """
    sentence_list = String.split(create_sentence, "\n")

    column_data = TableGenerator.extract_data(sentence_list, &TableGenerator.is_column_data?/1, &TableGenerator.generate_column_data/1)
    assert length(column_data) == 6
  end

  test "table data creates columns and keys" do
    create_sentence =
    """
    CREATE TABLE `test_table` (
    `id` char(12) COLLATE utf8_bin NOT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `name` varchar(150) COLLATE utf8_bin NOT NULL,
    `int_num` int(1) DEFAULT '0',
    `decimal_num` decimal(8,2) DEFAULT NULL,
    `double_num` double DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique01` (`name`),
    KEY `index01` (`int_num`,`decimal_num`),
    KEY `index02` (`double_num`),
    KEY `index03` (`timestamp`) USING BTREE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
    """
    table_data = %{table_name: "test_table", create_sentence: create_sentence}

    expect_columns =
    [
      Column.new("id", "char", true, nil, 12, nil),
      Column.new("timestamp", "timestamp", true, "CURRENT_TIMESTAMP", nil, nil),
      Column.new("name", "varchar", true, nil, 150, nil),
      Column.new("int_num", "int", false, "'0'", 1, nil),
      Column.new("decimal_num", "decimal", false, "NULL", 8, 2),
      Column.new("double_num", "double", false, "NULL", nil, nil)
    ]
    expect_keys =
    [
      Key.new(nil, :primary, ["id"]),
      Key.new("unique01", :unique, ["name"]),
      Key.new("index01", :key, ["int_num","decimal_num"]),
      Key.new("index02", :key, ["double_num"]),
      Key.new("index03", :key, ["timestamp"])
    ]
    expect_table = Table.new(expect_columns,expect_keys)

    assert TableGenerator.generate_from_table_data(table_data) == expect_table

  end
end
