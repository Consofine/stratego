defmodule StrategoWeb.Services.RandomService do
  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def generate_uid do
    random_bytes = :crypto.strong_rand_bytes(6)

    random_bytes
    |> :binary.bin_to_list()
    |> Enum.map(&byte_to_char/1)
    |> List.to_string()
  end

  defp byte_to_char(byte) do
    index = byte |> rem(26)
    String.at(@alphabet, index)
  end
end
