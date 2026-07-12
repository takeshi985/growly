defmodule Backend.Content.OptionsTest do
  use ExUnit.Case, async: true

  alias Backend.Content.Options

  test "parses and formats human-friendly options text" do
    assert {:ok, %{"a" => "кот", "b" => "дом", "c" => "лес"}} =
             Options.parse("a=кот\nb=дом\nc=лес")

    assert Options.format(%{"right" => "5", "left" => "3"}) == "left=3\nright=5"
  end

  test "rejects empty, malformed, and duplicate options" do
    assert {:error, _message} = Options.parse("")
    assert {:error, _message} = Options.parse("left")
    assert {:error, _message} = Options.parse("left=3\nleft=5")
  end
end
