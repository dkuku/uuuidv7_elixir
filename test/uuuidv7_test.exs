defmodule UUUIDv7Test do
  use ExUnit.Case
  doctest UUUIDv7

  test "bingenerate generates sorted UUIDs" do
    uuids =
      for _ <- 1..10000 do
        UUUIDv7.bingenerate()
      end

    sorted_uuids = Enum.sort(uuids)
    string_uuids = Enum.map(uuids, &UUUIDv7.encode/1)

    string_sorted_uuids =
      Enum.map(sorted_uuids, &UUUIDv7.encode/1)

    assert string_uuids == string_sorted_uuids
  end

  test "generate generates sorted UUIDs" do
    string_uuids =
      for _ <- 1..10000 do
        UUUIDv7.generate()
      end

    sorted_uuids =
      Enum.sort(string_uuids)

    assert string_uuids == sorted_uuids
  end
end
